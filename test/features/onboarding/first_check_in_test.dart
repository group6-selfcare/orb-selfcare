import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';
import 'package:orb_pm/data/db/app_database.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/data/profile/profile_repository.dart';
import 'package:orb_pm/features/onboarding/onboarding_routes.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/container_scope.dart';
import '../../helpers/test_database.dart';

void main() {
  late GoRouter router;
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() => db = memoryDatabase());

  String location() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
  final skip = find.byKey(const ValueKey('check-in-skip'));
  final good = find.byKey(const ValueKey('level-good'));
  final rough = find.byKey(const ValueKey('level-rough'));

  Future<void> start(WidgetTester tester, {Trait trait = Trait.playful}) async {
    SharedPreferences.setMockInitialValues({
      'profile.userName': 'Dara',
      'profile.pigName': 'Mochi',
      'profile.trait': trait.name,
      'profile.onboardingDone': false,
    });
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(tester.view.reset);
    router = createRouter(initialLocation: OnboardingRoutes.you);
    container = ProviderContainer(
      overrides: [
        routerProvider.overrideWithValue(router),
        inMemoryDatabase(db),
      ],
    );
    await tester.pumpWidget(
      ContainerScope(container: container, child: const OrbApp()),
    );
    await tester.pumpAndSettle();
    router.push(OnboardingRoutes.firstCheckIn);
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<CheckIn?> today() => CheckInRepository(db).getToday();

  testWidgets('N12 has its own title and question, and no tab bar', (
    tester,
  ) async {
    await start(tester);

    expect(find.text(CheckInCopy.firstTitle), findsOneWidget);
    expect(find.text(CheckInCopy.firstQuestion), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(skip, findsNothing);
  });

  testWidgets('tapping a level saves a real check-in for today', (
    tester,
  ) async {
    await start(tester);

    await tapAndSettle(tester, good);

    expect((await today())?.level, 4);
    expect(find.text(CheckInCopy.continueLabel), findsOneWidget);
    expect(skip, findsOneWidget);
  });

  testWidgets('Continue opens N15 with the trait line', (tester) async {
    await start(tester);
    await tapAndSettle(tester, good);

    await tapAndSettle(tester, find.text(CheckInCopy.continueLabel));

    expect(location(), OnboardingRoutes.dayOne);
    expect(find.text(OnboardingCopy.dayOneTitle), findsOneWidget);
    expect(
      find.text(
        OnboardingCopy.dayOneLine(
          trait: Trait.playful,
          level: 4,
          userName: 'Dara',
        ),
      ),
      findsOneWidget,
    );
    final svgs = find
        .byType(SvgPicture)
        .evaluate()
        .map((e) => (e.widget as SvgPicture).bytesLoader)
        .whereType<SvgAssetLoader>()
        .map((l) => l.assetName);
    expect(svgs, contains('assets/svg/pig/pig_cheer.svg'));
  });

  testWidgets('Skip also opens N15, keeping the check-in', (tester) async {
    await start(tester);
    await tapAndSettle(tester, good);

    await tapAndSettle(tester, skip);

    expect(location(), OnboardingRoutes.dayOne);
    expect((await today())?.level, 4);
  });

  testWidgets('after a Rough check-in every trait speaks gently', (
    tester,
  ) async {
    await start(tester, trait: Trait.cheerful);
    await tapAndSettle(tester, rough);
    await tapAndSettle(tester, find.text(CheckInCopy.continueLabel));

    final line = tester.widget<Text>(
      find.byKey(const ValueKey('day-one-line')),
    );
    expect(
      line.data,
      OnboardingCopy.dayOneLine(
        trait: Trait.gentle,
        level: 1,
        userName: 'Dara',
      ),
    );
  });

  testWidgets('N15 never shows an empty name or the wrong line', (
    tester,
  ) async {
    await start(tester);
    await tapAndSettle(tester, rough);
    final expected = OnboardingCopy.dayOneLine(
      trait: Trait.playful,
      level: 1,
      userName: 'Dara',
    );

    // Record the line on every frame of the slide-in, from the first one.
    await tester.tap(find.text(CheckInCopy.continueLabel));
    final seen = <String?>{};
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final line = find.byKey(const ValueKey('day-one-line'));
      if (line.evaluate().isNotEmpty) seen.add(tester.widget<Text>(line).data);
    }
    await tester.pumpAndSettle();

    expect(location(), OnboardingRoutes.dayOne);
    expect(seen, {expected}, reason: 'every frame that shows a line');
  });

  testWidgets('N15 opened without a level reads today\'s check-in', (
    tester,
  ) async {
    await start(tester);
    await CheckInRepository(db).saveToday(level: 2);

    router.push(OnboardingRoutes.dayOne);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('day-one-line'))).data,
      OnboardingCopy.dayOneLine(
        trait: Trait.playful,
        level: 2,
        userName: 'Dara',
      ),
    );
  });

  testWidgets('Go to Home finishes onboarding and clears the stack', (
    tester,
  ) async {
    await start(tester);
    await tapAndSettle(tester, good);
    await tapAndSettle(tester, find.text(CheckInCopy.continueLabel));
    expect(container.read(profileProvider).value?.onboardingDone, isFalse);

    await tapAndSettle(tester, find.text(OnboardingCopy.dayOneButton));

    expect(location(), '/home');
    expect(container.read(profileProvider).value?.onboardingDone, isTrue);
    expect(router.canPop(), isFalse);
    // Home shows today's check-in, so the empty Today card is gone.
    expect(find.text(HomeCopy.todayEmptyTitle), findsNothing);
  });

  testWidgets('back from N15 returns to the check-in, ready to continue', (
    tester,
  ) async {
    await start(tester);
    await tapAndSettle(tester, good);
    await tapAndSettle(tester, find.text(CheckInCopy.continueLabel));

    router.pop();
    await tester.pumpAndSettle();
    expect(location(), OnboardingRoutes.firstCheckIn);

    await tapAndSettle(tester, find.text(CheckInCopy.continueLabel));
    expect(location(), OnboardingRoutes.dayOne);
  });

  group('dayOneLine', () {
    test('has a line for every trait, using the name', () {
      final lines = {
        for (final trait in Trait.values)
          OnboardingCopy.dayOneLine(trait: trait, level: 4, userName: 'Dara'),
      };
      expect(lines, hasLength(3));
      expect(lines.every((l) => l.contains('Dara')), isTrue);
    });

    test('Rough and Low get the same gentle line for every trait', () {
      for (final level in [1, 2]) {
        final lines = {
          for (final trait in Trait.values)
            OnboardingCopy.dayOneLine(
              trait: trait,
              level: level,
              userName: 'Dara',
            ),
        };
        expect(lines, hasLength(1));
      }
    });
  });
}
