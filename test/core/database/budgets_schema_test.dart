import 'package:finora/core/database/database_migrator.dart';
import 'package:finora/core/database/schema_migrations.dart';
import 'package:finora/core/database/tables/budgets_table.dart';
import 'package:finora/core/database/tables/categories_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('v3 to v4 upgrade creates the budgets table and indexes', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DatabaseMigrator({
      1: schemaMigrations[1]!,
      2: schemaMigrations[2]!,
      3: schemaMigrations[3]!,
    }).onCreate(db);

    await DatabaseMigrator(schemaMigrations).onUpgrade(db, 3, 4);

    final tables = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table' AND name = ?",
      whereArgs: [BudgetsTable.name],
    );
    final indexes = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' "
      "AND name LIKE 'idx_budgets_%'",
    );
    expect(tables, hasLength(1));
    expect(
      indexes.map((row) => row['name']),
      containsAll([BudgetsTable.indexPeriod, BudgetsTable.indexCategory]),
    );
    await db.close();
  });

  test('budget category_type is locked to expense', () async {
    final db = await _openMigrated();
    await _seedCategory(db, type: 'expense');

    expect(
      _insertBudget(db, categoryType: 'income'),
      throwsA(isA<DatabaseException>()),
    );
    await db.close();
  });

  test('budget cannot reference an income category', () async {
    final db = await _openMigrated();
    await _seedCategory(db, type: 'income');

    expect(_insertBudget(db), throwsA(isA<DatabaseException>()));
    await db.close();
  });

  test('amount must be positive and period must be a real month', () async {
    final db = await _openMigrated();
    await _seedCategory(db);

    expect(
      _insertBudget(db, id: 'b0', amountMinor: 0),
      throwsA(isA<DatabaseException>()),
    );
    expect(
      _insertBudget(db, id: 'b13', period: '2026-13'),
      throwsA(isA<DatabaseException>()),
    );
    await db.close();
  });

  test('one budget is allowed per category and month', () async {
    final db = await _openMigrated();
    await _seedCategory(db);
    await _insertBudget(db);

    expect(_insertBudget(db, id: 'b2'), throwsA(isA<DatabaseException>()));
    await db.close();
  });

  test('category deletion is restricted while budgets exist', () async {
    final db = await _openMigrated();
    await _seedCategory(db);
    await _insertBudget(db);

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

Future<void> _insertBudget(
  Database db, {
  String id = 'b1',
  String categoryType = 'expense',
  String period = '2026-01',
  int amountMinor = 10000,
}) => db.insert(BudgetsTable.name, <String, Object?>{
  BudgetsTable.columnId: id,
  BudgetsTable.columnCategoryId: 'c1',
  BudgetsTable.columnCategoryType: categoryType,
  BudgetsTable.columnPeriod: period,
  BudgetsTable.columnAmountMinor: amountMinor,
  BudgetsTable.columnCreatedAt: '2026-01-01T00:00:00.000Z',
  BudgetsTable.columnUpdatedAt: '2026-01-01T00:00:00.000Z',
});
