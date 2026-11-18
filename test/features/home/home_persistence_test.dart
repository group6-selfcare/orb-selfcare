import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:orb_pm/shared/pig_pose.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'profile.userName': 'Dara',
      'profile.pigName': 'Mochi',
      'profile.trait': 'gentle',
      'profile.onboardingDone': true,
    });
  });

  Iterable<String> svgAssets() => find
      .byType(SvgPicture)
      .evaluate()
      .map((e) => (e.widget as SvgPicture).bytesLoader)
      .whereType<SvgAssetLoader>()
      .map((l) => l.assetName);

  void phoneSize(WidgetTester tester) {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(tester.view.reset);
  }

  testWidgets('a check-in is still on Home after the app restarts', (
    tester,
  ) async {
    phoneSize(tester);
    final dir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('orb_restart'),
    );
    addTearDown(() => dir!.deleteSync(recursive: true));
    final file = File('${dir!.path}/orb.sqlite');

    Future<void> launch() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routerProvider.overrideWithValue(createRouter()),
            overrideDatabase(fileDatabase(file)),
          ],
          child: const OrbApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    await launch();
    expect(find.text(HomeCopy.todayEmptyTitle), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-check-in-pill')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('level-good')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('check-in-done')));
    await tester.pumpAndSettle();
    expect(find.text('Feeling Good'), findsOneWidget);

    // "Kill" the app: the container and its database close.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    await launch();
    expect(find.text('Feeling Good'), findsOneWidget);
    expect(find.text(HomeCopy.todayEmptyTitle), findsNothing);
    expect(svgAssets(), contains(PigPose.forLevel(4).asset));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('home-greeting'))).data,
      HomeCopy.greetingFor(
        trait: Trait.gentle,
        level: 4,
        userName: 'Dara',
        pigName: 'Mochi',
      ),
    );
  });

  testWidgets('after midnight Home starts fresh on the next resume', (
    tester,
  ) async {
    phoneSize(tester);
    var now = DateTime(2026, 11, 18, 23, 58);
    final db = memoryDatabase();
    await CheckInRepository(db, now: () => now).saveToday(level: 5);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(createRouter()),
          overrideDatabase(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const OrbApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Feeling Great'), findsOneWidget);

    now = DateTime(2026, 11, 19, 0, 2);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Feeling Great'), findsNothing);
    expect(find.text(HomeCopy.todayEmptyTitle), findsOneWidget);
  });
}
