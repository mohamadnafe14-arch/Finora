import 'package:finora/core/database/database_migrator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('onCreate applies all migrations in order', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final applied = <int>[];
    final migrator = DatabaseMigrator({
      1: (database) async {
        applied.add(1);
        await database.execute('CREATE TABLE first (id INTEGER PRIMARY KEY)');
      },
      2: (database) async {
        applied.add(2);
        await database.execute('CREATE TABLE second (id INTEGER PRIMARY KEY)');
      },
    });

    await migrator.onCreate(db);

    expect(applied, [1, 2]);
    expect(migrator.schemaVersion, 2);
    await db.close();
  });

  test(
    'onUpgrade applies only migrations newer than the old version',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      final applied = <int>[];
      final migrator = DatabaseMigrator({
        1: (database) async => applied.add(1),
        2: (database) async => applied.add(2),
      });

      await migrator.onUpgrade(db, 1, 2);

      expect(applied, [2]);
      await db.close();
    },
  );
}
