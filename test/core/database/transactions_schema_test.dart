import 'package:finora/core/database/database_migrator.dart';
import 'package:finora/core/database/schema_migrations.dart';
import 'package:finora/core/database/tables/categories_table.dart';
import 'package:finora/core/database/tables/transactions_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('v2 to v3 upgrade creates the transactions table and indexes', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DatabaseMigrator({1: schemaMigrations[1]!, 2: schemaMigrations[2]!})
        .onCreate(db);

    await DatabaseMigrator(schemaMigrations).onUpgrade(db, 2, 3);

    final tables = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table' AND name = ?",
      whereArgs: [TransactionsTable.name],
    );
    final indexes = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' "
      "AND name LIKE 'idx_transactions_%'",
    );
    expect(tables, hasLength(1));
    expect(
      indexes.map((row) => row['name']),
      containsAll([
        TransactionsTable.indexDate,
        TransactionsTable.indexCategory,
      ]),
    );
    await db.close();
  });

  test('transaction type must match its category type', () async {
    final db = await _openMigrated();
    await _seedCategory(db, type: 'expense');

    expect(
      _insertTransaction(db, type: 'income'),
      throwsA(isA<DatabaseException>()),
    );
    await db.close();
  });

  test('amount must be positive', () async {
    final db = await _openMigrated();
    await _seedCategory(db);

    expect(
      _insertTransaction(db, amountMinor: 0),
      throwsA(isA<DatabaseException>()),
    );
    await db.close();
  });

  test('category deletion is restricted while transactions exist', () async {
    final db = await _openMigrated();
    await _seedCategory(db);
    await _insertTransaction(db);

    expect(
      db.delete(CategoriesTable.name, where: 'id = ?', whereArgs: ['c1']),
      throwsA(isA<DatabaseException>()),
    );
    await db.close();
  });
}

Future<Database> _openMigrated() async {
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('PRAGMA foreign_keys = ON');
  await DatabaseMigrator(schemaMigrations).onCreate(db);
  return db;
}

Future<void> _seedCategory(Database db, {String type = 'expense'}) =>
    db.insert(CategoriesTable.name, <String, Object?>{
      CategoriesTable.columnId: 'c1',
      CategoriesTable.columnName: 'Groceries',
      CategoriesTable.columnType: type,
      CategoriesTable.columnCreatedAt: '2026-01-01T00:00:00.000Z',
      CategoriesTable.columnUpdatedAt: '2026-01-01T00:00:00.000Z',
    });

Future<void> _insertTransaction(
  Database db, {
  String type = 'expense',
  int amountMinor = 100,
}) => db.insert(TransactionsTable.name, <String, Object?>{
  TransactionsTable.columnId: 't1',
  TransactionsTable.columnCategoryId: 'c1',
  TransactionsTable.columnType: type,
  TransactionsTable.columnAmountMinor: amountMinor,
  TransactionsTable.columnDate: '2026-01-15T10:00:00.000Z',
  TransactionsTable.columnCreatedAt: '2026-01-01T00:00:00.000Z',
  TransactionsTable.columnUpdatedAt: '2026-01-01T00:00:00.000Z',
});
