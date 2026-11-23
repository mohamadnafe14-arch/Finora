import 'package:finora/core/database/database_migrator.dart';
import 'package:finora/core/database/schema_migrations.dart';
import 'package:finora/core/database/tables/categories_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('schema version reflects every registered migration', () {
    expect(DatabaseMigrator(schemaMigrations).schemaVersion, 4);
  });

  test('fresh database receives the categories table', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DatabaseMigrator(schemaMigrations).onCreate(db);

    final tables = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table' AND name = ?",
      whereArgs: [CategoriesTable.name],
    );

    expect(tables, hasLength(1));
    await db.close();
  });

  test('v1 to v2 upgrade creates the categories columns', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DatabaseMigrator({1: schemaMigrations[1]!}).onCreate(db);

    await DatabaseMigrator(schemaMigrations).onUpgrade(db, 1, 2);

    final columns = await db.rawQuery(
      'PRAGMA table_info(${CategoriesTable.name})',
    );
    expect(
      columns.map((row) => row['name']),
      containsAll([
        CategoriesTable.columnId,
        CategoriesTable.columnName,
        CategoriesTable.columnType,
        CategoriesTable.columnCreatedAt,
        CategoriesTable.columnUpdatedAt,
      ]),
    );
    await db.close();
  });

  test('categories enforce type and case-insensitive unique names', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DatabaseMigrator(schemaMigrations).onCreate(db);
    final row = <String, Object?>{
      CategoriesTable.columnCreatedAt: '2026-01-01T00:00:00.000Z',
      CategoriesTable.columnUpdatedAt: '2026-01-01T00:00:00.000Z',
    };

    await db.insert(CategoriesTable.name, <String, Object?>{
      ...row,
      CategoriesTable.columnId: '1',
      CategoriesTable.columnName: 'Groceries',
      CategoriesTable.columnType: 'expense',
    });

    expect(
      db.insert(CategoriesTable.name, <String, Object?>{
        ...row,
        CategoriesTable.columnId: '2',
        CategoriesTable.columnName: 'groceries',
        CategoriesTable.columnType: 'expense',
      }),
      throwsA(isA<DatabaseException>()),
    );
    expect(
      db.insert(CategoriesTable.name, <String, Object?>{
        ...row,
        CategoriesTable.columnId: '3',
        CategoriesTable.columnName: 'Salary',
        CategoriesTable.columnType: 'transfer',
      }),
      throwsA(isA<DatabaseException>()),
    );
    await db.close();
  });
}
