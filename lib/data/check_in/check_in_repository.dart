import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import 'check_in.dart';

export '../db/app_database.dart' show Tag;
export 'check_in.dart';

/// Reads and writes the daily check-in.
///
/// Screens use this (through its providers), never drift directly, so a
/// cloud backend could replace it later without touching the UI.
///
/// There's one check-in per day. Saving again on the same day updates it.
class CheckInRepository {
  CheckInRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Today's key, read fresh on every call so it rolls over at midnight.
  String get _today => dayKey(_now());

  /// Today's check-in, or null, and every change to it.
  ///
  /// Each save rewrites the check_ins row, so tag-only edits emit too.
  Stream<CheckIn?> watchToday() =>
      _todayQuery(_today).watchSingleOrNull().asyncMap(_withTags);

  Future<CheckIn?> getToday() async =>
      _withTags(await _todayQuery(_today).getSingleOrNull());

  /// Saves today's check-in: inserts it the first time, then updates it.
  ///
  /// Every field is replaced, so pass the whole check-in. [tagIds] replace
  /// the old tags; they aren't added to them. A blank [note] is stored as
  /// null.
  Future<void> saveToday({
    required int level,
    String? emotion,
    String? note,
    Set<String> tagIds = const {},
  }) {
    RangeError.checkValueInInterval(level, 1, 5, 'level');
    final now = _now();
    final day = dayKey(now);
    final trimmed = note?.trim();
    final cleanNote = (trimmed == null || trimmed.isEmpty) ? null : trimmed;

    return _db.transaction(() async {
      final existing = await _todayQuery(day).getSingleOrNull();
      final int id;
      if (existing == null) {
        id = await _db
            .into(_db.checkIns)
            .insert(
              CheckInsCompanion.insert(
                day: day,
                level: level,
                emotion: Value(emotion),
                note: Value(cleanNote),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        id = existing.id;
        await (_db.update(_db.checkIns)..where((c) => c.id.equals(id))).write(
          CheckInsCompanion(
            level: Value(level),
            emotion: Value(emotion),
            note: Value(cleanNote),
            updatedAt: Value(now),
          ),
        );
      }

      await (_db.delete(
        _db.checkInTags,
      )..where((t) => t.checkInId.equals(id))).go();
      await _db.batch((b) {
        b.insertAll(_db.checkInTags, [
          for (final tagId in tagIds)
            CheckInTagsCompanion.insert(checkInId: id, tagId: tagId),
        ]);
      });
    });
  }

  /// All 18 tags, primary ones first, in display order.
  Future<List<Tag>> allTags() => (_db.select(
    _db.tags,
  )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();

  SimpleSelectStatement<$CheckInsTable, CheckInRow> _todayQuery(String day) =>
      _db.select(_db.checkIns)..where((c) => c.day.equals(day));

  Future<CheckIn?> _withTags(CheckInRow? row) async {
    if (row == null) return null;
    final links = await (_db.select(
      _db.checkInTags,
    )..where((t) => t.checkInId.equals(row.id))).get();
    return CheckIn(
      id: row.id,
      day: row.day,
      level: row.level,
      emotion: row.emotion,
      note: row.note,
      tagIds: {for (final link in links) link.tagId},
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

/// The app's database, opened once and closed with the app.
///
/// Tests override it with `AppDatabase.forTesting(NativeDatabase.memory())`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// What time it is. Tests override it to pin "today".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => CheckInRepository(
    ref.watch(appDatabaseProvider),
    now: ref.watch(clockProvider),
  ),
);

/// Today's check-in, or null before the user checks in. Updates live.
///
/// The stream follows the day it started on, so the provider rebuilds
/// itself for the new day:
/// - at the next local midnight, and
/// - when the app comes back to the foreground, because timers don't run
///   reliably while the phone sleeps.
final todayCheckInProvider = StreamProvider<CheckIn?>((ref) {
  final now = ref.watch(clockProvider)();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  final timer = Timer(midnight.difference(now), ref.invalidateSelf);
  final lifecycle = AppLifecycleListener(onResume: ref.invalidateSelf);
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
  return ref.watch(checkInRepositoryProvider).watchToday();
});

/// The 18 tags in display order. The first 8 are primary.
final tagsProvider = FutureProvider<List<Tag>>(
  (ref) => ref.watch(checkInRepositoryProvider).allTags(),
);
