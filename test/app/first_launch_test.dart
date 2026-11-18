import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/first_launch.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/app/shell/splash_screen.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/data/profile/profile_repository.dart';
import 'package:orb_pm/features/home/home_screen.dart';
import 'package:orb_pm/features/onboarding/meet_screen.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/container_scope.dart';
import '../helpers/test_database.dart';

void main() {
  group('firstLaunchRedirect', () {
    const loading = AsyncLoading<Profile>();
    const fresh = AsyncData(Profile.empty);
    const halfway = AsyncData(
      Profile(userName: 'Dara', pigName: 'Mochi', trait: Trait.gentle),
    );
    const done = AsyncData(Profile(onboardingDone: true));

    test('waits on the splash while the profile loads', () {
      expect(firstLaunchRedirect(loading, splashPath), isNull);
      expect(firstLaunchRedirect(loading, '/home'), splashPath);
      expect(firstLaunchRedirect(loading, onboardingStartPath), splashPath);
    });

    test('a new or half-onboarded user goes to N1, never a tab', () {
      for (final profile in [fresh, halfway]) {
        expect(firstLaunchRedirect(profile, splashPath), onboardingStartPath);
        for (final tab in ['/home', '/space', '/quest', '/profile']) {
          expect(firstLaunchRedirect(profile, tab), onboardingStartPath);
        }
      }
    });

    test('onboarding and check-in stay reachable during onboarding', () {
      expect(firstLaunchRedirect(fresh, onboardingStartPath), isNull);
      expect(firstLaunchRedirect(fresh, '/onboarding/done'), isNull);
      expect(firstLaunchRedirect(fresh, '/check-in'), isNull);
    });

    test('a returning user goes from the splash to Home', () {
      expect(firstLaunchRedirect(done, splashPath), '/home');
      expect(firstLaunchRedirect(done, '/home'), isNull);
      expect(firstLaunchRedirect(done, '/space'), isNull);
    });

    test('an unreadable profile is treated as new', () {
      final error = AsyncError<Profile>(Exception('disk'), StackTrace.empty);
      expect(firstLaunchRedirect(error, splashPath), onboardingStartPath);
    });
  });

  group('cold start', () {
    Future<ProviderContainer> launch(
      WidgetTester tester,
      Map<String, Object> stored,
    ) async {
      SharedPreferences.setMockInitialValues(stored);
      final container = ProviderContainer(overrides: [inMemoryDatabase()]);
      await tester.pumpWidget(
        ContainerScope(container: container, child: const OrbApp()),
      );
      return container;
    }

    String location(ProviderContainer c) => c
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .last
        .matchedLocation;

    testWidgets('first frame is the splash, not Home or onboarding', (
      tester,
    ) async {
      await launch(tester, {'profile.onboardingDone': true});

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(MeetScreen), findsNothing);
    });

    testWidgets('a fresh install opens onboarding N1', (tester) async {
      final c = await launch(tester, {});
      await tester.pumpAndSettle();

      expect(location(c), onboardingStartPath);
      expect(find.byType(MeetScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('quitting halfway restarts onboarding from N1', (tester) async {
      final c = await launch(tester, {
        'profile.userName': 'Dara',
        'profile.pigName': 'Mochi',
        'profile.trait': 'gentle',
      });
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(location(c), onboardingStartPath);
    });

    testWidgets('a returning user opens Home directly', (tester) async {
      final c = await launch(tester, {'profile.onboardingDone': true});
      await tester.pumpAndSettle();

      expect(location(c), '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Home is blocked until onboarding is completed', (
      tester,
    ) async {
      final c = await launch(tester, {});
      await tester.pumpAndSettle();
      final router = c.read(routerProvider);

      router.go('/home');
      await tester.pumpAndSettle();
      expect(location(c), onboardingStartPath);

      // What N15 does: mark onboarding done, then go Home.
      await c.read(profileProvider.notifier).completeOnboarding();
      router.go('/home');
      await tester.pumpAndSettle();
      expect(location(c), '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('walking through onboarding and the debug Finish', (
      tester,
    ) async {
      final c = await launch(tester, {});
      await tester.pumpAndSettle();

      await tester.tap(find.text("Let's begin"));
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text(OnboardingCopy.next));
        await tester.pumpAndSettle();
      }
      await tester.enterText(find.byType(TextField), 'Dara');
      await tester.pump();
      await tester.tap(find.text(OnboardingCopy.next));
      await tester.pumpAndSettle();

      // N4 saved the answers, but onboarding isn't done until N15.
      final saved = c.read(profileProvider).value!;
      expect(saved.userName, 'Dara');
      expect(saved.pigName, OnboardingCopy.pigNames.first);
      expect(saved.onboardingDone, isFalse);

      await tester.tap(find.text('Finish (debug)'));
      await tester.pumpAndSettle();

      expect(location(c), '/home');
      expect(c.read(profileProvider).value?.onboardingDone, isTrue);
    });

    testWidgets('the debug Reset onboarding on Home starts again at N1', (
      tester,
    ) async {
      final c = await launch(tester, {
        'profile.userName': 'Dara',
        'profile.pigName': 'Mochi',
        'profile.onboardingDone': true,
      });
      await tester.pumpAndSettle();
      expect(location(c), '/home');

      // The debug tools sit at the bottom of Home, below the Today card.
      final reset = find.text('Reset onboarding (debug)');
      await tester.scrollUntilVisible(reset, 200);
      await tester.tap(reset);
      await tester.pumpAndSettle();

      expect(location(c), onboardingStartPath);
      expect(find.byType(MeetScreen), findsOneWidget);
      expect(c.read(profileProvider).value, Profile.empty);
      expect(await ProfileRepository().load(), Profile.empty);
    });
  });
}
