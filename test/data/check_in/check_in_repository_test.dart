import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';
import 'package:orb_pm/data/db/app_database.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late CheckInRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9, 30);
    repo = CheckInRepository(db, now: () => now);
  });
  tearDown(() => db.close());

  Future<int> rowCount() async => (await db.select(db.checkIns).get()).length;

  group('dayKey', () {
    test('is the local date as yyyy-MM-dd', () {
      expect(dayKey(DateTime(2026, 3, 7, 12)), '2026-03-07');
    });

    test('23:59 and 00:01 fall on different days', () {
      expect(dayKey(DateTime(2026, 11, 18, 23, 59)), '2026-11-18');
      expect(dayKey(DateTime(2026, 11, 19, 0, 1)), '2026-11-19');
    });
  });

  test('getToday() returns null on a fresh database', () async {
    expect(await repo.getToday(), isNull);
  });

  test('the first save creates a row', () async {
    await repo.saveToday(level: 4);

    final today = await repo.getToday();
    expect(await rowCount(), 1);
    expect(today?.day, '2026-11-18');
    expect(today?.level, 4);
    expect(today?.emotion, isNull);
    expect(today?.tagIds, isEmpty);
  });

  test('a second save on the same day updates the same row', () async {
    await repo.saveToday(level: 2);
    final first = await repo.getToday();
    now = now.add(const Duration(hours: 3));

    await repo.saveToday(level: 5, emotion: 'excited', note: ' Great day ');

    final second = await repo.getToday();
    expect(await rowCount(), 1);
    expect(second?.id, first?.id);
    expect(second?.level, 5);
    expect(second?.emotion, 'excited');
    expect(second?.note, 'Great day');
    expect(second?.createdAt, first?.createdAt);
    expect(second?.updatedAt, now);
  });

  test('a blank note is stored as null', () async {
    await repo.saveToday(level: 3, note: '   ');

    expect((await repo.getToday())?.note, isNull);
  });

  test('tags are replaced on update, not appended', () async {
    await repo.saveToday(level: 3, tagIds: {'work', 'family'});
    await repo.saveToday(level: 3, tagIds: {'family', 'health'});

    expect((await repo.getToday())?.tagIds, {'family', 'health'});
    expect(await db.select(db.checkInTags).get(), hasLength(2));
  });

  test('after midnight, today is a new, empty day', () async {
    now = DateTime(2026, 11, 18, 23, 59);
    await repo.saveToday(level: 1);

    now = DateTime(2026, 11, 19, 0, 1);
    expect(await repo.getToday(), isNull);

    await repo.saveToday(level: 4);
    expect(await rowCount(), 2);
    expect((await repo.getToday())?.level, 4);
  });

  test('watchToday() emits null, then each save', () async {
    final seen = <int?>[];
    final sub = repo.watchToday().listen((c) => seen.add(c?.level));
    await pumpEventQueue();

    await repo.saveToday(level: 2);
    await pumpEventQueue();
    await repo.saveToday(level: 4, tagIds: {'work'});
    await pumpEventQueue();
    await sub.cancel();

    expect(seen, [null, 2, 4]);
  });

  test('a level outside 1 to 5 is rejected', () {
    expect(() => repo.saveToday(level: 0), throwsRangeError);
    expect(() => repo.saveToday(level: 6), throwsRangeError);
  });

  test('allTags() lists 18 tags with the 8 primary ones first', () async {
    final tags = await repo.allTags();

    expect(tags, hasLength(18));
    expect(tags.take(8).map((t) => t.id), [
      'work',
      'education',
      'family',
      'friends',
      'health',
      'selfCare',
      'money',
      'partner',
    ]);
  });
}
