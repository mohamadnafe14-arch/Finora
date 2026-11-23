import 'package:finora/core/database/app_database.dart';
import 'package:finora/core/database/database_migrator.dart';
import 'package:finora/core/database/schema_migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('opens the database at the current schema version', () async {
    final appDatabase = AppDatabase(databaseFactoryFfi);

    final db = await appDatabase.database;

    expect(db.isOpen, isTrue);
    expect(
      await db.getVersion(),
      DatabaseMigrator(schemaMigrations).schemaVersion,
    );
    await appDatabase.close();
  });

  test('returns the same database instance on repeated access', () async {
    final appDatabase = AppDatabase(databaseFactoryFfi);

    final first = await appDatabase.database;
    final second = await appDatabase.database;

    expect(first, same(second));
    await appDatabase.close();
  });
}
