import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/data/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  CheckInsCompanion checkIn(String day, {int level = 3}) {
    final now = DateTime(2026, 11, 18, 9);
    return CheckInsCompanion.insert(
      day: day,
      level: level,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('schema version is 1', () {
    expect(db.schemaVersion, 1);
  });

  test("seeds Apple's 18 State of Mind tags", () async {
    final tags = await db.select(db.tags).get();

    expect(tags.map((t) => t.label).toSet(), {
      'Community',
      'Current Events',
      'Dating',
      'Education',
      'Family',
      'Fitness',
      'Friends',
      'Health',
      'Hobbies',
      'Identity',
      'Money',
      'Partner',
      'Self Care',
      'Spirituality',
      'Tasks',
      'Travel',
      'Weather',
      'Work',
    });
  });

  test('exactly 8 tags are primary, first and in order', () async {
    final tags = await (db.select(
      db.tags,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();

    expect(tags.where((t) => t.isPrimary).map((t) => t.label), [
      'Work',
      'Education',
      'Family',
      'Friends',
      'Health',
      'Self Care',
      'Money',
      'Partner',
    ]);
    expect(tags.take(8).every((t) => t.isPrimary), isTrue);
    expect(tags.map((t) => t.sortOrder), List.generate(18, (i) => i));
  });

  test('a second check-in for the same day fails', () async {
    await db.into(db.checkIns).insert(checkIn('2026-11-18'));

    expect(
      db.into(db.checkIns).insert(checkIn('2026-11-18', level: 5)),
      throwsA(isA<SqliteException>()),
    );
    await db.into(db.checkIns).insert(checkIn('2026-11-19'));
    expect(await db.select(db.checkIns).get(), hasLength(2));
  });

  test('a level outside 1 to 5 fails', () async {
    expect(
      db.into(db.checkIns).insert(checkIn('2026-11-18', level: 6)),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a check-in removes its tag links', () async {
    final id = await db.into(db.checkIns).insert(checkIn('2026-11-18'));
    await db
        .into(db.checkInTags)
        .insert(CheckInTagsCompanion.insert(checkInId: id, tagId: 'work'));

    await (db.delete(db.checkIns)..where((c) => c.id.equals(id))).go();

    expect(await db.select(db.checkInTags).get(), isEmpty);
    expect(await db.select(db.tags).get(), hasLength(18));
  });
}
