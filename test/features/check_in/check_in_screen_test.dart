import 'package:flutter/material.dart';

import 'dart:ui' show Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';
import 'package:orb_pm/data/db/app_database.dart';
import 'package:orb_pm/features/check_in/mood_level.dart';
import 'package:orb_pm/features/home/home_screen.dart';
import 'package:orb_pm/shared/copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';

/// Records every save before passing it on to the real repository.
class SpyCheckInRepository extends CheckInRepository {
  SpyCheckInRepository(super.db);

  final levels = <int>[];

  @override
  Future<void> saveToday({
    required int level,
    String? emotion,
    String? note,
    Set<String> tagIds = const {},
  }) {
    levels.add(level);
    return super.saveToday(
      level: level,
      emotion: emotion,
      note: note,
      tagIds: tagIds,
    );
  }
}

void main() {
  late GoRouter router;
  late AppDatabase db;
  late SpyCheckInRepository repo;

  /// Opens Home for a returning user, then the check-in from it.
  Future<void> openCheckIn(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'profile.userName': 'Dara',
      'profile.pigName': 'Mochi',
      'profile.trait': 'gentle',
      'profile.onboardingDone': true,
    });
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(tester.view.reset);
    db = memoryDatabase();
    repo = SpyCheckInRepository(db);
    router = createRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          inMemoryDatabase(db),
          checkInRepositoryProvider.overrideWithValue(repo),
        ],
        child: const OrbApp(),
      ),
    );
    await tester.pumpAndSettle();
    router.push(checkInPath);
    await tester.pumpAndSettle();
  }

  String location() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;

  Finder face(MoodLevel level) => find.byKey(ValueKey('level-${level.name}'));
  bool isSelected(WidgetTester tester, MoodLevel level) =>
      tester.getSemantics(face(level)).flagsCollection.isSelected ==
      Tristate.isTrue;
  final extras = find.byKey(const ValueKey('check-in-extras'));
  final done = find.byKey(const ValueKey('check-in-done'));

  testWidgets('shows the pig, the question and 5 labelled faces', (
    tester,
  ) async {
    await openCheckIn(tester);

    expect(find.text(CheckInCopy.question), findsOneWidget);
    expect(find.bySemanticsLabel('Your pig companion, waving'), findsOneWidget);
    for (final name in ['Rough', 'Low', 'Okay', 'Good', 'Great']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(extras, findsNothing);
    expect(done, findsNothing);
  });

  testWidgets('tapping Good saves level 4 straight away', (tester) async {
    await openCheckIn(tester);

    await tester.tap(face(MoodLevel.good));
    await tester.pumpAndSettle();

    expect(repo.levels, [4]);
    expect((await repo.getToday())?.level, 4);
  });

  testWidgets('a tap highlights the face and opens the extras and Done', (
    tester,
  ) async {
    await openCheckIn(tester);

    await tester.tap(face(MoodLevel.low));
    await tester.pumpAndSettle();

    expect(isSelected(tester, MoodLevel.low), isTrue);
    expect(isSelected(tester, MoodLevel.good), isFalse);
    expect(extras, findsOneWidget);
    expect(done, findsOneWidget);
  });

  testWidgets('Done returns to Home with the check-in saved', (tester) async {
    await openCheckIn(tester);
    await tester.tap(face(MoodLevel.great));
    await tester.pumpAndSettle();

    await tester.tap(done);
    await tester.pumpAndSettle();

    expect(location(), '/home');
    expect((await repo.getToday())?.level, 5);
  });

  testWidgets('back without a face saves nothing', (tester) async {
    await openCheckIn(tester);

    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();

    expect(location(), '/home');
    expect(repo.levels, isEmpty);
    expect(await repo.getToday(), isNull);
  });

  testWidgets('back after a face keeps the check-in', (tester) async {
    await openCheckIn(tester);
    await tester.tap(face(MoodLevel.rough));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(OnboardingCopy.back));
    await tester.pumpAndSettle();

    expect(location(), '/home');
    expect((await repo.getToday())?.level, 1);
  });

  testWidgets('every face is a 48dp target with a TalkBack label', (
    tester,
  ) async {
    await openCheckIn(tester);

    for (final level in MoodLevel.values) {
      final size = tester.getSize(face(level));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(face(level)).label,
        CheckInCopy.levelSemantics(level),
      );
    }
    expect(CheckInCopy.levelSemantics(MoodLevel.low), 'Feeling Low');
  });

  test('levels map to 1 to 5 in order', () {
    expect(MoodLevel.values.map((l) => l.value), [1, 2, 3, 4, 5]);
    expect(MoodLevel.fromValue(4), MoodLevel.good);
  });

  testWidgets('every level face SVG is bundled', (tester) async {
    for (final level in MoodLevel.values) {
      final svg = await rootBundle.loadString(moodFaceAsset(level.face));
      expect(svg, startsWith('<svg'));
    }
  });
}
