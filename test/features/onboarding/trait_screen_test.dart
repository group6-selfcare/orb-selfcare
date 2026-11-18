import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/features/onboarding/onboarding_draft.dart';
import 'package:orb_pm/features/onboarding/onboarding_routes.dart';
import 'package:orb_pm/features/onboarding/trait_screen.dart';
import 'package:orb_pm/shared/copy.dart';

void main() {
  late GoRouter router;
  late ProviderContainer container;

  /// Opens N1, then walks forward to N3 with the default pig name.
  Future<void> pumpN3(WidgetTester tester) async {
    // A typical 393 x 852 phone.
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(tester.view.reset);
    router = createRouter(initialLocation: OnboardingRoutes.meet);
    container = ProviderContainer(
      overrides: [routerProvider.overrideWithValue(router)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OrbApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.meetButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
  }

  String location() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
  Finder card(Trait t) => find.byKey(ValueKey('trait-${t.name}'));
  bool isSelected(WidgetTester tester, Trait t) =>
      tester.getSemantics(card(t)).flagsCollection.isSelected ==
      Tristate.isTrue;

  testWidgets('shows the title and three cards with copy', (tester) async {
    await pumpN3(tester);

    expect(find.byType(TraitScreen), findsOneWidget);
    expect(find.text(OnboardingCopy.traitTitle), findsOneWidget);
    for (final t in Trait.values) {
      expect(find.text(OnboardingCopy.traitName[t]!), findsOneWidget);
      expect(find.text(OnboardingCopy.traitDescription[t]!), findsOneWidget);
      expect(find.text(OnboardingCopy.traitSample[t]!), findsOneWidget);
    }
  });

  testWidgets('Gentle is preselected', (tester) async {
    await pumpN3(tester);

    expect(isSelected(tester, Trait.gentle), isTrue);
    expect(isSelected(tester, Trait.cheerful), isFalse);
    expect(isSelected(tester, Trait.playful), isFalse);
  });

  testWidgets('exactly one card is selected at a time', (tester) async {
    await pumpN3(tester);

    for (final picked in [Trait.playful, Trait.cheerful, Trait.gentle]) {
      await tester.tap(card(picked));
      await tester.pumpAndSettle();
      for (final t in Trait.values) {
        expect(isSelected(tester, t), t == picked, reason: '$picked picked');
      }
    }
  });

  testWidgets('Next stores the trait and goes to N4', (tester) async {
    await pumpN3(tester);

    await tester.tap(card(Trait.cheerful));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();

    expect(location(), OnboardingRoutes.you);
    expect(container.read(onboardingDraftProvider).trait, Trait.cheerful);
  });

  testWidgets('keeping Gentle still stores it', (tester) async {
    await pumpN3(tester);

    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();

    expect(container.read(onboardingDraftProvider).trait, Trait.gentle);
  });

  testWidgets('going back and forward keeps the selection', (tester) async {
    await pumpN3(tester);
    await tester.tap(card(Trait.playful));
    await tester.pumpAndSettle();

    // Back to N2, then forward again.
    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    expect(isSelected(tester, Trait.playful), isTrue);

    // Forward to N4, then back.
    await tester.tap(find.text(OnboardingCopy.next));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();
    expect(isSelected(tester, Trait.playful), isTrue);
  });

  testWidgets('TalkBack reads each card as one selectable button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpN3(tester);

    for (final t in Trait.values) {
      expect(
        tester.getSemantics(card(t)),
        matchesSemantics(
          label:
              '${OnboardingCopy.traitName[t]}. '
              '${OnboardingCopy.traitDescription[t]}. '
              '${OnboardingCopy.traitSample[t]}',
          isButton: true,
          hasSelectedState: true,
          isSelected: t == Trait.gentle,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
    }

    // Double-tapping with TalkBack selects the card.
    tester.semantics.tap(find.semantics.byLabel(RegExp('^Playful')));
    await tester.pumpAndSettle();
    expect(isSelected(tester, Trait.playful), isTrue);
    semantics.dispose();
  });
}
