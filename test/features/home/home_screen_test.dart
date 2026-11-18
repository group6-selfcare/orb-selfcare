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
import 'package:orb_pm/features/check_in/mood_level.dart';
import 'package:orb_pm/features/home/home_screen.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:orb_pm/shared/pig_pose.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';

void main() {
  late GoRouter router;

  /// Opens Home for a user called Dara whose pig is Mochi, and returns its
  /// database. [checkedInAt] is when the check-in is saved (default now).
  Future<AppDatabase> pumpHome(
    WidgetTester tester, {
    Trait trait = Trait.cheerful,
    int? checkedInLevel,
    String? emotion,
    String? note,
    Set<String> tagIds = const {},
    DateTime? checkedInAt,
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
    final db = memoryDatabase();
    if (checkedInLevel != null) {
      await CheckInRepository(
        db,
        now: checkedInAt == null ? null : () => checkedInAt,
      ).saveToday(
        level: checkedInLevel,
        emotion: emotion,
        note: note,
        tagIds: tagIds,
      );
    }
    router = createRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          overrideDatabase(db),
        ],
        child: const OrbApp(),
      ),
    );
    await tester.pumpAndSettle();
    return db;
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

  group('after check-in', () {
    testWidgets('the pig takes the pose for the level', (tester) async {
      for (final (level, pose) in [
        (1, PigPose.comforting),
        (2, PigPose.listening),
        (3, PigPose.calm),
        (4, PigPose.joyful),
        (5, PigPose.cheering),
      ]) {
        await pumpHome(tester, checkedInLevel: level);
        expect(svgAssets(), contains(pose.asset), reason: 'level $level');
        expect(svgAssets(), isNot(contains(PigPose.curious.asset)));
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('the greeting is greetingFor(trait, level)', (tester) async {
      await pumpHome(tester, trait: Trait.playful, checkedInLevel: 2);

      expect(
        tester.widget<Text>(find.byKey(const ValueKey('home-greeting'))).data,
        HomeCopy.greetingFor(
          trait: Trait.playful,
          level: 2,
          userName: 'Dara',
          pigName: 'Mochi',
        ),
      );
    });

    testWidgets('the Today card shows level, emotion, note and tags', (
      tester,
    ) async {
      await pumpHome(
        tester,
        checkedInLevel: 4,
        emotion: 'peaceful',
        note: 'Walked by the river after class and it really helped',
        tagIds: {'family', 'selfCare'},
      );

      expect(find.text(HomeCopy.todayEmptyTitle), findsNothing);
      expect(find.text('Feeling Good'), findsOneWidget);
      expect(find.text('Peaceful'), findsOneWidget);
      final note = tester.widget<Text>(
        find.byKey(const ValueKey('home-today-note')),
      );
      expect(note.maxLines, 2);
      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Self Care'), findsOneWidget);
    });

    testWidgets('the Today card draws the level face file', (tester) async {
      await pumpHome(tester, checkedInLevel: 4);

      expect(svgAssets(), contains(levelFaceAsset(MoodLevel.good)));
    });

    testWidgets('tags show in display order, not the order picked', (
      tester,
    ) async {
      await pumpHome(tester, checkedInLevel: 4, tagIds: {'selfCare', 'work'});

      expect(
        tester.getTopLeft(find.text('Work')).dx,
        lessThan(tester.getTopLeft(find.text('Self Care')).dx),
      );
    });

    testWidgets('the time is the first check-in, even after an edit', (
      tester,
    ) async {
      final today = DateTime.now();
      DateTime at(int hour, int minute) =>
          DateTime(today.year, today.month, today.day, hour, minute);
      final db = await pumpHome(
        tester,
        checkedInLevel: 2,
        checkedInAt: at(9, 5),
      );

      await tester.runAsync(
        () => CheckInRepository(db, now: () => at(18, 30)).saveToday(level: 5),
      );
      await tester.pumpAndSettle();

      expect(find.text('Feeling Great'), findsOneWidget);
      expect(find.textContaining('9:05 AM'), findsOneWidget);
      expect(find.textContaining('6:30 PM'), findsNothing);
    });

    testWidgets('a level-only check-in shows just the level', (tester) async {
      await pumpHome(tester, checkedInLevel: 3);

      expect(find.text('Feeling Okay'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-today-emotion')), findsNothing);
      expect(find.byKey(const ValueKey('home-today-note')), findsNothing);
    });

    testWidgets('the button turns into a quieter Edit', (tester) async {
      await pumpHome(tester, checkedInLevel: 4);

      expect(find.byTooltip(HomeCopy.editCheckIn), findsOneWidget);
      expect(find.byTooltip(HomeCopy.checkIn), findsNothing);
      expect(
        find.descendant(of: pill, matching: find.byType(SvgPicture)),
        findsNothing,
      );
    });

    testWidgets('tapping the Today card opens the check-in to edit', (
      tester,
    ) async {
      await pumpHome(tester, checkedInLevel: 4);

      await tester.ensureVisible(todayCard);
      await tester.tap(todayCard);
      await tester.pumpAndSettle();

      expect(location(), checkInPath);
      expect(find.text(CheckInCopy.editTitle), findsOneWidget);
    });

    testWidgets('an edit shows on Home straight away', (tester) async {
      await pumpHome(tester, checkedInLevel: 2);
      await tester.tap(pill);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('level-great')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('check-in-done')));
      await tester.pumpAndSettle();

      expect(location(), '/home');
      expect(find.text('Feeling Great'), findsOneWidget);
      expect(svgAssets(), contains(PigPose.cheering.asset));
    });
  });
}
