import 'package:sqflite/sqflite.dart';

/// A single schema migration step.
typedef MigrationStep = Future<void> Function(Database db);

/// Applies ordered schema migrations to the application database.
class DatabaseMigrator {
  /// Creates a migrator with migrations keyed by target schema version.
  DatabaseMigrator(Map<int, MigrationStep> migrations)
    : _migrations = Map.unmodifiable(migrations);

  final Map<int, MigrationStep> _migrations;

  /// Latest schema version covered by the registered migrations.
  int get schemaVersion => _migrations.keys.fold<int>(
    0,
    (max, version) => version > max ? version : max,
  );

  /// Applies every migration to a freshly created database.
  Future<void> onCreate(Database db) => _apply(db, 0, schemaVersion);

  /// Applies migrations newer than [oldVersion] up to [newVersion].
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) =>
      _apply(db, oldVersion, newVersion);

  Future<void> _apply(Database db, int from, int to) async {
    for (var version = from + 1; version <= to; version++) {
      final step = _migrations[version];
      if (step != null) {
        await step(db);
      }
    }
  }
}
