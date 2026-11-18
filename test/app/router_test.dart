import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/app/shell/orb_tab.dart';
import 'package:orb_pm/features/home/home_screen.dart';

void main() {
  late GoRouter router;

  Future<void> pumpApp(WidgetTester tester) async {
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

  Finder tab(OrbTab t) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(t.label),
  );

  testWidgets('starts on Home with four tabs', (tester) async {
    await pumpApp(tester);

    expect(location(), '/home');
    expect(find.byType(HomeScreen), findsOneWidget);
    for (final t in OrbTab.values) {
      expect(tab(t), findsOneWidget);
    }
  });

  testWidgets('the selected tab shows its active icon, others inactive', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(tab(OrbTab.quest));
    await tester.pumpAndSettle();

    expect(location(), '/quest');
    final assets = svgAssets();
    expect(assets, contains(OrbTab.quest.activeIcon));
    expect(assets, isNot(contains(OrbTab.home.activeIcon)));
    expect(assets, contains(OrbTab.home.inactiveIcon));
  });

  testWidgets('Space, Quest and Profile show a coming soon placeholder', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final t in [OrbTab.space, OrbTab.quest, OrbTab.profile]) {
      await tester.tap(tab(t));
      await tester.pumpAndSettle();
      expect(location(), t.path);
      expect(find.text('Coming soon'), findsOneWidget);
    }
  });

  testWidgets('each tab keeps its own stack', (tester) async {
    await pumpApp(tester);
    await tester.tap(tab(OrbTab.space));
    await tester.pumpAndSettle();

    // Home stays alive offstage while Space is showing.
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);

    await tester.tap(tab(OrbTab.home));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('check-in and onboarding hide the tab bar', (tester) async {
    await pumpApp(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byTooltip('Check in'));
    await tester.pumpAndSettle();
    expect(location(), '/check-in');
    expect(find.byType(NavigationBar), findsNothing);

    router.go('/onboarding');
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Android back from another tab returns to Home', (tester) async {
    await pumpApp(tester);
    await tester.tap(tab(OrbTab.profile));
    await tester.pumpAndSettle();
    expect(location(), '/profile');

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(location(), '/home');
  });

  testWidgets('Android back on Home is left to the system', (tester) async {
    await pumpApp(tester);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Not handled by the app means Android closes it as usual.
    expect(handled, isFalse);
  });
}

/// The asset names of every SVG on screen.
Iterable<String> svgAssets() => find
    .byType(SvgPicture)
    .evaluate()
    .map((e) => (e.widget as SvgPicture).bytesLoader)
    .whereType<SvgAssetLoader>()
    .map((l) => l.assetName);
