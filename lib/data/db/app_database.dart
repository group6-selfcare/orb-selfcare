import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// One row per day. The day key is the local date, so a second check-in on
/// the same day updates this row instead of adding one.
@DataClassName('CheckInRow')
class CheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The local date as yyyy-MM-dd. Unique: one check-in per day.
  TextColumn get day => text().withLength(min: 10, max: 10).unique()();

  /// The mood level, 1 (Rough) to 5 (Great).
  // drift reads `level` here as the column, not a recursive call.
  // ignore: recursive_getters
  IntColumn get level => integer().check(level.isBetweenValues(1, 5))();

  /// The optional emotion, a `Mood` name such as "happy".
  TextColumn get emotion => text().nullable()();

  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// The "What's it about?" tags: Apple's State of Mind associations.
class Tags extends Table {
  /// Apple's association id, e.g. "selfCare" for
  /// `HKStateOfMind.Association.selfCare`.
  TextColumn get id => text()();
  TextColumn get label => text()();

  /// The order the chips are shown in. The primary tags come first.
  IntColumn get sortOrder => integer()();

  /// Shown before "More tags" is opened.
  BoolColumn get isPrimary => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Which tags a check-in has. Deleting either side removes the link.
class CheckInTags extends Table {
  IntColumn get checkInId =>
      integer().references(CheckIns, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {checkInId, tagId};
}

/// A tag seeded on first launch.
typedef SeedTag = ({String id, String label});

/// The 8 tags shown first, in this order.
const primaryTags = <SeedTag>[
  (id: 'work', label: 'Work'),
  (id: 'education', label: 'Education'),
  (id: 'family', label: 'Family'),
  (id: 'friends', label: 'Friends'),
  (id: 'health', label: 'Health'),
  (id: 'selfCare', label: 'Self Care'),
  (id: 'money', label: 'Money'),
  (id: 'partner', label: 'Partner'),
];

/// The other 10, shown under "More tags", alphabetically.
const moreTags = <SeedTag>[
  (id: 'community', label: 'Community'),
  (id: 'currentEvents', label: 'Current Events'),
  (id: 'dating', label: 'Dating'),
  (id: 'fitness', label: 'Fitness'),
  (id: 'hobbies', label: 'Hobbies'),
  (id: 'identity', label: 'Identity'),
  (id: 'spirituality', label: 'Spirituality'),
  (id: 'tasks', label: 'Tasks'),
  (id: 'travel', label: 'Travel'),
  (id: 'weather', label: 'Weather'),
];

/// The app's local SQLite database. Check-in history lives here so later
/// features (habits, the journey, the mood calendar) can query it.
///
/// UI code never uses this directly: it goes through `CheckInRepository`.
@DriftDatabase(tables: [CheckIns, Tags, CheckInTags])
class AppDatabase extends _$AppDatabase {
  /// Opens `orb.sqlite` in the app's documents folder.
  AppDatabase() : super(driftDatabase(name: 'orb'));

  /// For tests, e.g. `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedTags();
    },
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off unless asked, and the cascade
      // deletes on check_in_tags need them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedTags() async {
    var order = 0;
    await batch((b) {
      for (final (tags, primary) in [(primaryTags, true), (moreTags, false)]) {
        for (final tag in tags) {
          b.insert(
            this.tags,
            TagsCompanion.insert(
              id: tag.id,
              label: tag.label,
              sortOrder: order++,
              isPrimary: primary,
            ),
          );
        }
      }
    });
  }
}
