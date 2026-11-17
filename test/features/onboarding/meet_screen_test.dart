import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/features/onboarding/meet_screen.dart';
import 'package:orb_pm/features/onboarding/onboarding_draft.dart';
import 'package:orb_pm/features/onboarding/onboarding_routes.dart';
import 'package:orb_pm/features/onboarding/onboarding_scaffold.dart';
import 'package:orb_pm/shared/copy.dart';

void main() {
  late GoRouter router;
  late ProviderContainer container;

  Future<void> pumpOnboarding(WidgetTester tester) async {
    router = createRouter(initialLocation: OnboardingRoutes.meet);
    container = ProviderContainer(
      overrides: [routerProvider.overrideWithValue(router)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OrbApp()),
    );
    await tester.pumpAndSettle();
  }

  String location() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;

  Iterable<String> svgAssets() => find
      .byType(SvgPicture)
      .evaluate()
      .map((e) => (e.widget as SvgPicture).bytesLoader)
      .whereType<SvgAssetLoader>()
      .map((l) => l.assetName);

  testWidgets('N1 shows the waving pig, title, promises and Let\'s begin', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.byType(MeetScreen), findsOneWidget);
    expect(svgAssets(), contains('assets/svg/pig/pig_wave.svg'));
    expect(find.text(OnboardingCopy.meetTitle), findsOneWidget);
    for (final promise in OnboardingCopy.meetPromises) {
      expect(find.text(promise), findsOneWidget);
    }
    expect(find.text(OnboardingCopy.meetFootnote), findsOneWidget);
    expect(find.text(OnboardingCopy.meetButton), findsOneWidget);
    expect(find.text('I already have an account'), findsNothing);
  });

  testWidgets('N1 is a clean welcome: no back arrow or progress bar', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.byTooltip(OnboardingCopy.back), findsNothing);
    expect(find.byType(OnboardingProgress), findsNothing);
  });

  testWidgets("Let's begin goes to N2, which has the shared top bar", (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();

    expect(location(), OnboardingRoutes.name);
    expect(find.byTooltip(OnboardingCopy.back), findsOneWidget);
    expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
  });

  testWidgets('the progress fill grows with the step', (tester) async {
    await pumpOnboarding(tester);
    double fillWidth() => tester
        .getSize(find.byKey(const ValueKey('onboarding-progress-fill')))
        .width;

    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();
    final step2 = fillWidth();

    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    final step3 = fillWidth();

    expect(step3, greaterThan(step2));
  });

  testWidgets('Android back on N1 is left to the system', (tester) async {
    await pumpOnboarding(tester);

    final handled = await tester.binding.handlePopRoute();

    // Not handled by the app means Android closes it.
    expect(handled, isFalse);
  });

  testWidgets('Android back and the back arrow each go back one step', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    expect(location(), OnboardingRoutes.trait);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(location(), OnboardingRoutes.name);

    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();
    expect(location(), OnboardingRoutes.meet);
  });

  testWidgets('answers survive going back and forward', (tester) async {
    await pumpOnboarding(tester);
    final draft = container.read(onboardingDraftProvider.notifier);

    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();
    draft
      ..setPigName('Mochi')
      ..setTrait(Trait.playful);

    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();

    final answers = container.read(onboardingDraftProvider);
    expect(answers.pigName, 'Mochi');
    expect(answers.trait, Trait.playful);
  });
}
