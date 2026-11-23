import 'package:sqflite/sqflite.dart';

/// Schema constants for the `budgets` table.
abstract final class BudgetsTable {
  static const name = 'budgets';
  static const columnId = 'id';
  static const columnCategoryId = 'category_id';
  static const columnCategoryType = 'category_type';
  static const columnPeriod = 'period';
  static const columnAmountMinor = 'amount_minor';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';
  static const indexPeriod = 'idx_budgets_period';
  static const indexCategory = 'idx_budgets_category';

  static const expenseType = 'expense';

  static const createSql =
      '''
    CREATE TABLE IF NOT EXISTS $name (
      $columnId TEXT PRIMARY KEY,
      $columnCategoryId TEXT NOT NULL,
      $columnCategoryType TEXT NOT NULL
        DEFAULT '$expenseType'
        CHECK ($columnCategoryType = '$expenseType'),
      $columnPeriod TEXT NOT NULL CHECK (
        $columnPeriod GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]'
        AND CAST(substr($columnPeriod, 6, 2) AS INTEGER) BETWEEN 1 AND 12
      ),
      $columnAmountMinor INTEGER NOT NULL CHECK ($columnAmountMinor > 0),
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      UNIQUE ($columnCategoryId, $columnPeriod),
      FOREIGN KEY ($columnCategoryId, $columnCategoryType)
        REFERENCES categories(id, type)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    )
  ''';

  static const createPeriodIndexSql =
      'CREATE INDEX IF NOT EXISTS $indexPeriod ON $name($columnPeriod DESC)';

  static const createCategoryIndexSql =
      'CREATE INDEX IF NOT EXISTS $indexCategory ON $name($columnCategoryId)';
}

/// Applies the v4 budgets migration.
Future<void> createBudgetsTable(Database db) async {
  await db.execute(BudgetsTable.createSql);
  await db.execute(BudgetsTable.createPeriodIndexSql);
  await db.execute(BudgetsTable.createCategoryIndexSql);
}
