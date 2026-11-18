import 'package:flutter/material.dart';

import 'dart:ui' show Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';
import 'package:orb_pm/app/theme/tokens.dart';
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
  final emotions = <String?>[];

  @override
  Future<void> saveToday({
    required int level,
    String? emotion,
    String? note,
    Set<String> tagIds = const {},
  }) {
    levels.add(level);
    emotions.add(emotion);
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
  Future<void> openCheckIn(
    WidgetTester tester, {
    Future<void> Function(AppDatabase db)? seed,
  }) async {
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
    if (seed != null) await seed(db);
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

  testWidgets('every level has its own face SVG, flat for flutter_svg', (
    tester,
  ) async {
    expect(MoodLevel.values.map(levelFaceAsset), [
      'assets/svg/mood/level_rough.svg',
      'assets/svg/mood/level_low.svg',
      'assets/svg/mood/level_okay.svg',
      'assets/svg/mood/level_good.svg',
      'assets/svg/mood/level_great.svg',
    ]);
    for (final level in MoodLevel.values) {
      final svg = await tester.runAsync(
        () => rootBundle.loadString(levelFaceAsset(level), cache: false),
      );
      expect(svg, startsWith('<svg'), reason: level.name);
      for (final tag in ['<mask', '<filter', '<image', '<text']) {
        expect(svg, isNot(contains(tag)), reason: '${level.name} $tag');
      }
    }
  });

  testWidgets('the check-in buttons draw the level faces', (tester) async {
    await openCheckIn(tester);

    final assets = find
        .byType(SvgPicture)
        .evaluate()
        .map((e) => (e.widget as SvgPicture).bytesLoader)
        .whereType<SvgAssetLoader>()
        .map((l) => l.assetName);
    for (final level in MoodLevel.values) {
      expect(assets, contains(levelFaceAsset(level)), reason: level.name);
    }
  });

  group('emotion step', () {
    Finder emotion(Mood mood) => find.byKey(ValueKey('emotion-${mood.name}'));
    bool emotionSelected(WidgetTester tester, Mood mood) =>
        tester.getSemantics(emotion(mood)).flagsCollection.isSelected ==
        Tristate.isTrue;

    Future<void> pickLevel(WidgetTester tester, MoodLevel level) async {
      await tester.ensureVisible(face(level));
      await tester.pumpAndSettle();
      await tester.tap(face(level));
      await tester.pumpAndSettle();
    }

    Future<void> pickEmotion(WidgetTester tester, Mood mood) async {
      await tester.ensureVisible(emotion(mood));
      await tester.pumpAndSettle();
      await tester.tap(emotion(mood));
      await tester.pumpAndSettle();
    }

    testWidgets('"Want to name it?" shows the 4 faces for the level', (
      tester,
    ) async {
      await openCheckIn(tester);
      expect(find.text(CheckInCopy.emotionTitle), findsNothing);

      await pickLevel(tester, MoodLevel.low);

      expect(find.text(CheckInCopy.emotionTitle), findsOneWidget);
      for (final mood in Mood.values) {
        expect(
          emotion(mood),
          emotionsForLevel[MoodLevel.low]!.contains(mood)
              ? findsOneWidget
              : findsNothing,
          reason: mood.name,
        );
      }
    });

    testWidgets('tapping an emotion saves it; tapping again clears it', (
      tester,
    ) async {
      await openCheckIn(tester);
      await pickLevel(tester, MoodLevel.good);

      await pickEmotion(tester, Mood.peaceful);
      expect(emotionSelected(tester, Mood.peaceful), isTrue);
      expect((await repo.getToday())?.emotion, 'peaceful');

      await pickEmotion(tester, Mood.peaceful);
      expect(emotionSelected(tester, Mood.peaceful), isFalse);
      expect((await repo.getToday())?.emotion, isNull);
      expect(repo.emotions, [null, 'peaceful', null]);
    });

    testWidgets('only one emotion is selected at a time', (tester) async {
      await openCheckIn(tester);
      await pickLevel(tester, MoodLevel.great);

      await pickEmotion(tester, Mood.happy);
      await pickEmotion(tester, Mood.loved);

      expect(emotionSelected(tester, Mood.happy), isFalse);
      expect(emotionSelected(tester, Mood.loved), isTrue);
      expect((await repo.getToday())?.emotion, 'loved');
    });

    testWidgets('a new level keeps the emotion only if it still fits', (
      tester,
    ) async {
      await openCheckIn(tester);
      await pickLevel(tester, MoodLevel.good);
      await pickEmotion(tester, Mood.happy);

      // Great also offers Happy.
      await pickLevel(tester, MoodLevel.great);
      expect((await repo.getToday())?.emotion, 'happy');

      // Low doesn't.
      await pickLevel(tester, MoodLevel.low);
      expect((await repo.getToday())?.emotion, isNull);
      expect((await repo.getToday())?.level, 2);
    });
  });

  group('emotionsForLevel', () {
    test('every level offers 3 to 4 emotions', () {
      for (final level in MoodLevel.values) {
        expect(
          emotionsForLevel[level],
          hasLength(inInclusiveRange(3, 4)),
          reason: level.name,
        );
      }
    });

    testWidgets('every emotion has a bundled SVG and a label', (tester) async {
      final moods = emotionsForLevel.values.expand((m) => m).toSet();
      for (final mood in moods) {
        final svg = await tester.runAsync(
          () => rootBundle.loadString(moodFaceAsset(mood), cache: false),
        );
        expect(svg, startsWith('<svg'), reason: mood.name);
        expect(CheckInCopy.emotionName[mood], isNotNull, reason: mood.name);
      }
    });

    test('stored names read back as moods', () {
      expect(moodFromName('happy'), Mood.happy);
      expect(moodFromName('unknown'), isNull);
      expect(moodFromName(null), isNull);
    });
  });

  group('note and tags', () {
    Finder tag(String id) => find.byKey(ValueKey('tag-$id'));
    final note = find.byKey(const ValueKey('check-in-note'));
    final moreTags = find.byKey(const ValueKey('more-tags'));

    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> pickOkay(WidgetTester tester) async {
      await tester.tap(face(MoodLevel.okay));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the note hint and the 8 primary tags', (tester) async {
      await openCheckIn(tester);
      await pickOkay(tester);

      expect(find.text(CheckInCopy.noteHint), findsOneWidget);
      expect(find.text(CheckInCopy.tagsTitle), findsOneWidget);
      for (final label in [
        'Work',
        'Education',
        'Family',
        'Friends',
        'Health',
        'Self Care',
        'Money',
        'Partner',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.byType(FilterChip), findsNWidgets(8));
      expect(find.text('Create a tag'), findsNothing);
    });

    testWidgets('"More tags" shows all 18', (tester) async {
      await openCheckIn(tester);
      await pickOkay(tester);

      await tapVisible(tester, moreTags);

      expect(find.byType(FilterChip), findsNWidgets(18));
      expect(find.text('Weather'), findsOneWidget);
      expect(find.text(CheckInCopy.fewerTags), findsOneWidget);
    });

    testWidgets('selecting Family and Work and tapping Done saves both', (
      tester,
    ) async {
      await openCheckIn(tester);
      await pickOkay(tester);

      await tapVisible(tester, tag('family'));
      await tapVisible(tester, tag('work'));
      await tester.tap(done);
      await tester.pumpAndSettle();

      expect(location(), '/home');
      expect((await repo.getToday())?.tagIds, {'family', 'work'});
    });

    testWidgets('tapping a picked tag again unpicks it', (tester) async {
      await openCheckIn(tester);
      await pickOkay(tester);

      await tapVisible(tester, tag('health'));
      await tapVisible(tester, tag('health'));
      await tester.tap(done);
      await tester.pumpAndSettle();

      expect((await repo.getToday())?.tagIds, isEmpty);
    });

    testWidgets('the note and tags are kept on back', (tester) async {
      await openCheckIn(tester);
      await pickOkay(tester);

      await tester.enterText(note, 'Long day of exams');
      await tapVisible(tester, tag('education'));
      await tester.tap(find.byTooltip(OnboardingCopy.back));
      await tester.pumpAndSettle();

      final today = await repo.getToday();
      expect(location(), '/home');
      expect(today?.note, 'Long day of exams');
      expect(today?.tagIds, {'education'});
    });

    testWidgets('the note stops at 500 characters', (tester) async {
      await openCheckIn(tester);
      await pickOkay(tester);

      await tester.enterText(note, 'a' * 600);
      await tester.pump();

      final field = tester.widget<TextField>(note);
      expect(field.controller!.text, hasLength(500));
      expect(find.text('500/500'), findsOneWidget);
    });
  });

  group('edit today', () {
    Future<void> seedToday(AppDatabase db) => CheckInRepository(db).saveToday(
      level: 2,
      emotion: 'sad',
      note: 'Missed the bus',
      tagIds: {'work', 'weather'},
    );
    Finder tag(String id) => find.byKey(ValueKey('tag-$id'));
    final note = find.byKey(const ValueKey('check-in-note'));

    testWidgets("today's check-in opens pre-filled as \"Edit today\"", (
      tester,
    ) async {
      await openCheckIn(tester, seed: seedToday);

      expect(find.text(CheckInCopy.editTitle), findsOneWidget);
      expect(isSelected(tester, MoodLevel.low), isTrue);
      expect(
        tester
                .getSemantics(find.byKey(const ValueKey('emotion-sad')))
                .flagsCollection
                .isSelected ==
            Tristate.isTrue,
        isTrue,
      );
      expect(tester.widget<TextField>(note).controller!.text, 'Missed the bus');
      expect(tester.widget<FilterChip>(tag('work')).selected, isTrue);
      // Weather isn't primary, but it's picked, so it shows folded too.
      expect(tester.widget<FilterChip>(tag('weather')).selected, isTrue);
      expect(done, findsOneWidget);
      expect(repo.levels, isEmpty, reason: 'opening saves nothing');
    });

    testWidgets('changing a value and Done updates the same row', (
      tester,
    ) async {
      await openCheckIn(tester, seed: seedToday);
      final before = await repo.getToday();

      await tester.tap(face(MoodLevel.good));
      await tester.pumpAndSettle();
      await tester.enterText(note, 'Bus came after all');
      await tester.ensureVisible(tag('work'));
      await tester.pumpAndSettle();
      await tester.tap(tag('work'));
      await tester.pumpAndSettle();
      await tester.tap(done);
      await tester.pumpAndSettle();

      final after = await repo.getToday();
      expect(await db.select(db.checkIns).get(), hasLength(1));
      expect(after?.id, before?.id);
      expect(after?.level, 4);
      expect(after?.emotion, isNull, reason: 'Good does not offer Sad');
      expect(after?.note, 'Bus came after all');
      expect(after?.tagIds, {'weather'});
      expect(location(), '/home');
    });

    testWidgets('on a new day the check-in starts empty', (tester) async {
      await openCheckIn(
        tester,
        seed: (db) => CheckInRepository(
          db,
          now: () => DateTime.now().subtract(const Duration(days: 1)),
        ).saveToday(level: 5, note: 'Yesterday'),
      );

      expect(find.text(CheckInCopy.title), findsOneWidget);
      for (final level in MoodLevel.values) {
        expect(isSelected(tester, level), isFalse);
      }
      expect(done, findsNothing);
    });
  });
}
