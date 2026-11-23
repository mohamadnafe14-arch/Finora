import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_migrator.dart';

/// Offline-first SQLite database of the application.
@lazySingleton
class AppDatabase {
  /// Creates the database access with its platform factory.
  AppDatabase(this._factory);

  final DatabaseFactory _factory;

  Database? _database;

  static final DatabaseMigrator _migrator = DatabaseMigrator({
    1: _createInitialSchema,
  });

  /// Opens the database once and returns the shared instance.
  Future<Database> get database async => _database ??= await _open();

  /// Closes the database, if open.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _open() async {
    final path = p.join(await _factory.getDatabasesPath(), 'finora.db');
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _migrator.schemaVersion,
        onCreate: (db, _) => _migrator.onCreate(db),
        onUpgrade: (db, oldVersion, newVersion) =>
            _migrator.onUpgrade(db, oldVersion, newVersion),
      ),
    );
  }

  /// Initial schema (v1). Feature tables are added by later milestones.
  static Future<void> _createInitialSchema(Database db) async {}
}
