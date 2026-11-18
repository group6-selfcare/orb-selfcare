import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';
import 'package:orb_pm/data/db/app_database.dart';

/// A fresh in-memory database for one test.
AppDatabase memoryDatabase() {
  // Each test opens its own database on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  // Closing streams right away keeps widget tests free of pending timers.
  return AppDatabase.forTesting(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}

/// Overrides the app's database with an in-memory one, closed with the
/// container. Add it to every ProviderScope that pumps the app.
Override inMemoryDatabase([AppDatabase? db]) =>
    appDatabaseProvider.overrideWith((ref) {
      final database = db ?? memoryDatabase();
      ref.onDispose(database.close);
      return database;
    });
