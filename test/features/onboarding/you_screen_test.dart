import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/data/profile/profile_repository.dart';
import 'package:orb_pm/features/onboarding/onboarding_draft.dart';
import 'package:orb_pm/features/onboarding/onboarding_routes.dart';
import 'package:orb_pm/features/onboarding/you_screen.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';

void main() {
  late GoRouter router;
  late ProviderContainer container;

  /// Walks N1 to N3 (naming the pig Mochi, picking Playful) and opens N4.
  Future<void> pumpN4(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(tester.view.reset);
    router = createRouter(initialLocation: OnboardingRoutes.meet);
    container = ProviderContainer(
      overrides: [routerProvider.overrideWithValue(router), inMemoryDatabase()],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OrbApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('pig-name-field')),
      'Mochi',
    );
    await tester.pump();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('trait-playful')));
    await tester.pump();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
  }

  String location() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
  final field = find.byKey(const ValueKey('user-name-field'));
  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(field).controller!.text;
  bool nextEnabled(WidgetTester tester) => tester
      .widget<FilledButton>(
        find.widgetWithText(FilledButton, OnboardingCopy.next),
      )
      .enabled;

  testWidgets('shows the question, hint, helper and the pig by name', (
    tester,
  ) async {
    await pumpN4(tester);

    expect(find.byType(YouScreen), findsOneWidget);
    expect(find.text(OnboardingCopy.youTitle), findsOneWidget);
    expect(find.text(OnboardingCopy.youHint), findsOneWidget);
    expect(find.text(OnboardingCopy.youHelper), findsOneWidget);
    expect(find.text(OnboardingCopy.youIntro('Mochi')), findsOneWidget);
  });

  testWidgets('the progress bar shows step 4 of 4', (tester) async {
    await pumpN4(tester);

    expect(find.bySemanticsLabel('Step 4 of 4'), findsOneWidget);
  });

  testWidgets('Next is disabled until a name is typed', (tester) async {
    await pumpN4(tester);
    expect(fieldText(tester), isEmpty);
    expect(nextEnabled(tester), isFalse);

    await tester.enterText(field, '   ');
    await tester.pump();
    expect(nextEnabled(tester), isFalse);

    await tester.enterText(field, 'Dara');
    await tester.pump();
    expect(nextEnabled(tester), isTrue);
  });

  testWidgets('typing stops at 20 characters', (tester) async {
    await pumpN4(tester);

    await tester.enterText(field, 'b' * 30);
    await tester.pump();

    expect(fieldText(tester).length, OnboardingCopy.nameMaxLength);
  });

  testWidgets('Next saves all answers and starts the first check-in', (
    tester,
  ) async {
    await pumpN4(tester);

    await tester.enterText(field, '  Dara  ');
    await tester.pump();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();

    expect(location(), OnboardingRoutes.firstCheckIn);
    expect(container.read(onboardingDraftProvider).userName, 'Dara');
    const expected = Profile(
      userName: 'Dara',
      pigName: 'Mochi',
      trait: Trait.playful,
    );
    expect(container.read(profileProvider).value, expected);
    // Saved to the device, and onboarding is not marked done yet.
    expect(await ProfileRepository().load(), expected);
  });

  testWidgets('going back and forward keeps the typed name', (tester) async {
    await pumpN4(tester);
    await tester.enterText(field, 'Dara');
    await tester.pump();

    // Back to N3 without pressing Next, then forward again.
    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    expect(fieldText(tester), 'Dara');

    // Forward to the first check-in, then back.
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(location(), OnboardingRoutes.you);
    expect(fieldText(tester), 'Dara');
  });
}
