import 'package:finora/core/database/database_migrator.dart';
import 'package:finora/core/database/database_provider.dart';
import 'package:finora/core/database/schema_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens an in-memory database with the current schema applied.
Future<Database> openTestDatabase() async {
  final migrator = DatabaseMigrator(schemaMigrations);
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: migrator.schemaVersion,
      onConfigure: _enableForeignKeys,
      onCreate: (db, _) => migrator.onCreate(db),
      onUpgrade: (db, oldVersion, newVersion) =>
          migrator.onUpgrade(db, oldVersion, newVersion),
    ),
  );
}

Future<void> _enableForeignKeys(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

/// Exposes a ready database through the application's [DatabaseProvider].
class TestDatabaseProvider implements DatabaseProvider {
  TestDatabaseProvider(this._database);

  final Database _database;

  @override
  Future<Database> get database async => _database;
}
