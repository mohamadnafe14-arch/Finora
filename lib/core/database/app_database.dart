import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_migrator.dart';
import 'database_provider.dart';
import 'schema_migrations.dart';

/// Offline-first SQLite database of the application.
@LazySingleton(as: DatabaseProvider)
class AppDatabase implements DatabaseProvider {
  /// Creates the database access with its platform factory.
  AppDatabase(this._factory);

  final DatabaseFactory _factory;

  Database? _database;

  static final DatabaseMigrator _migrator = DatabaseMigrator(schemaMigrations);

  /// Opens the database once and returns the shared instance.
  @override
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
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, _) => _migrator.onCreate(db),
        onUpgrade: (db, oldVersion, newVersion) =>
            _migrator.onUpgrade(db, oldVersion, newVersion),
      ),
    );
  }
}
