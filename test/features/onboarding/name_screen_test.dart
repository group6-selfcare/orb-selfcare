import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/features/onboarding/name_screen.dart';
import 'package:orb_pm/features/onboarding/onboarding_draft.dart';
import 'package:orb_pm/features/onboarding/onboarding_routes.dart';
import 'package:orb_pm/features/onboarding/pig_names.dart';
import 'package:orb_pm/shared/copy.dart';

void main() {
  group('pig names', () {
    test('the list has at least 10 different names', () {
      expect(OnboardingCopy.pigNames.toSet().length, greaterThanOrEqualTo(10));
    });

    test('a suggestion never repeats the current name', () {
      final random = Random(1);
      for (final name in OnboardingCopy.pigNames) {
        for (var i = 0; i < 50; i++) {
          expect(suggestPigName(name, random: random), isNot(name));
          expect(
            suggestPigName(' ${name.toLowerCase()} ', random: random),
            isNot(name),
          );
        }
      }
    });

    test('a name is trimmed and must be 1 to 20 characters', () {
      expect(validPigName('  Mochi  '), 'Mochi');
      expect(validPigName('   '), isNull);
      expect(validPigName(''), isNull);
      expect(validPigName('a' * 20), 'a' * 20);
      expect(validPigName('a' * 21), isNull);
    });
  });

  group('N2', () {
    late GoRouter router;
    late ProviderContainer container;

    Future<void> pumpN2(WidgetTester tester) async {
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
    }

    String location() =>
        router.routerDelegate.currentConfiguration.last.matchedLocation;
    final field = find.byKey(const ValueKey('pig-name-field'));
    String fieldText(WidgetTester tester) =>
        tester.widget<TextField>(field).controller!.text;
    bool nextEnabled(WidgetTester tester) => tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, OnboardingCopy.next),
        )
        .enabled;

    testWidgets('shows the pig, title and a pre-filled name', (tester) async {
      await pumpN2(tester);

      expect(find.byType(NameScreen), findsOneWidget);
      expect(find.text(OnboardingCopy.nameTitle), findsOneWidget);
      expect(fieldText(tester), OnboardingCopy.pigNames.first);
      expect(nextEnabled(tester), isTrue);
    });

    testWidgets('Suggest another name swaps in a different name', (
      tester,
    ) async {
      await pumpN2(tester);

      for (var i = 0; i < 10; i++) {
        final before = fieldText(tester);
        await tester.tap(find.text(OnboardingCopy.nameSuggest));
        await tester.pump();
        expect(fieldText(tester), isNot(before));
        expect(OnboardingCopy.pigNames, contains(fieldText(tester)));
      }
    });

    testWidgets('Next is disabled while the name is empty or blank', (
      tester,
    ) async {
      await pumpN2(tester);

      await tester.enterText(field, '   ');
      await tester.pump();
      expect(nextEnabled(tester), isFalse);

      await tester.enterText(field, 'Mochi');
      await tester.pump();
      expect(nextEnabled(tester), isTrue);
    });

    testWidgets('typing stops at 20 characters', (tester) async {
      await pumpN2(tester);

      await tester.enterText(field, 'a' * 30);
      await tester.pump();

      expect(fieldText(tester).length, OnboardingCopy.nameMaxLength);
    });

    testWidgets('Next saves the trimmed name and goes to N3', (tester) async {
      await pumpN2(tester);

      await tester.enterText(field, '  Mochi  ');
      await tester.tap(find.text(OnboardingCopy.next));
      await tester.pumpAndSettle();

      expect(location(), OnboardingRoutes.trait);
      expect(container.read(onboardingDraftProvider).pigName, 'Mochi');
    });

    testWidgets('going back and forward keeps the typed name', (tester) async {
      await pumpN2(tester);
      await tester.enterText(field, 'Num Pang');
      await tester.pump();

      // Back to N1 without pressing Next, then forward again.
      await tester.tap(find.byTooltip(OnboardingCopy.back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(OnboardingCopy.meetButton));
      await tester.pumpAndSettle();
      expect(fieldText(tester), 'Num Pang');

      // Forward to N3, then back.
      await tester.tap(find.text(OnboardingCopy.next));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(OnboardingCopy.back));
      await tester.pumpAndSettle();
      expect(fieldText(tester), 'Num Pang');
    });

    testWidgets('on a small phone the keyboard covers neither field nor Next', (
      tester,
    ) async {
      // A 320 x 568 phone with a 260-point keyboard open.
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(640, 1136);
      addTearDown(tester.view.reset);
      await pumpN2(tester);

      tester.view.viewInsets = const FakeViewPadding(bottom: 520);
      await tester.showKeyboard(field);
      await tester.pumpAndSettle();

      const visibleBottom = 568 - 260;
      final fieldBox = tester.getRect(field);
      final nextBox = tester.getRect(
        find.widgetWithText(FilledButton, OnboardingCopy.next),
      );
      expect(fieldBox.top, greaterThanOrEqualTo(0));
      expect(fieldBox.bottom, lessThanOrEqualTo(visibleBottom));
      expect(nextBox.bottom, lessThanOrEqualTo(visibleBottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('on a typical phone the question stays in view too', (
      tester,
    ) async {
      // A 393 x 852 phone with a 300-point keyboard open.
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(tester.view.reset);
      await pumpN2(tester);

      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      await tester.showKeyboard(field);
      await tester.pumpAndSettle();

      final titleBox = tester.getRect(find.text(OnboardingCopy.nameTitle));
      final nextBox = tester.getRect(
        find.widgetWithText(FilledButton, OnboardingCopy.next),
      );
      expect(titleBox.top, greaterThanOrEqualTo(48));
      expect(nextBox.bottom, lessThanOrEqualTo(852 - 300));
    });
  });
}
