import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/features/home/home_screen.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late GoRouter router;

  /// Opens Home for a user called Dara whose pig is Mochi.
  Future<void> pumpHome(
    WidgetTester tester, {
    Trait trait = Trait.cheerful,
  }) async {
    SharedPreferences.setMockInitialValues({
      'profile.userName': 'Dara',
      'profile.pigName': 'Mochi',
      'profile.trait': trait.name,
      'profile.onboardingDone': true,
    });
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(tester.view.reset);
    router = createRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(router)],
        child: const OrbApp(),
      ),
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

  final pill = find.byKey(const ValueKey('home-check-in-pill'));
  final todayCard = find.byKey(const ValueKey('home-today-card'));

  testWidgets('shows the Orb header with an icon-only Check in button', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text(HomeCopy.title), findsOneWidget);
    expect(pill, findsOneWidget);
    expect(tester.widget(pill), isA<IconButton>());
    expect(find.text(HomeCopy.checkIn), findsNothing);
    expect(find.byTooltip(HomeCopy.checkIn), findsOneWidget);
  });

  testWidgets('the Check in pill uses the custom check-in icon', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(
      find.descendant(of: pill, matching: find.byType(SvgPicture)),
      findsOneWidget,
    );
    expect(svgAssets(), contains(checkInIcon));
  });

  testWidgets('the pig stands in the hero with its name', (tester) async {
    await pumpHome(tester);

    expect(svgAssets(), contains('assets/svg/pig/pig_curious.svg'));
    expect(find.text('Mochi'), findsOneWidget);
  });

  for (final trait in Trait.values) {
    testWidgets('greets in the ${trait.name} voice with both names', (
      tester,
    ) async {
      await pumpHome(tester, trait: trait);

      final expected = HomeCopy.greetingBefore(
        trait: trait,
        userName: 'Dara',
        pigName: 'Mochi',
      );
      expect(find.text(expected), findsOneWidget);
      expect(expected, contains('Dara'));
      expect(expected, contains('Mochi'));
    });
  }

  testWidgets('with no check-in today, shows the empty Today card', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text(HomeCopy.todayEmptyTitle), findsOneWidget);
  });

  testWidgets('tapping the Check in pill opens the check-in', (tester) async {
    await pumpHome(tester);

    await tester.tap(pill);
    await tester.pumpAndSettle();
    expect(location(), checkInPath);
  });

  testWidgets('tapping the Today card opens the check-in', (tester) async {
    await pumpHome(tester);

    await tester.ensureVisible(todayCard);
    await tester.tap(todayCard);
    await tester.pumpAndSettle();
    expect(location(), checkInPath);
  });

  testWidgets('has no Journey, Your goal or Suggestions sections', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.textContaining('Journey'), findsNothing);
    expect(find.textContaining('Your goal'), findsNothing);
    expect(find.textContaining('Suggestions'), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
