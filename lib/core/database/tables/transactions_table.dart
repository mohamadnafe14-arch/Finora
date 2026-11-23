import 'package:sqflite/sqflite.dart';

/// Schema constants for the `transactions` table.
abstract final class TransactionsTable {
  static const name = 'transactions';
  static const columnId = 'id';
  static const columnCategoryId = 'category_id';
  static const columnType = 'type';
  static const columnAmountMinor = 'amount_minor';
  static const columnNote = 'note';
  static const columnDate = 'transaction_date';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';
  static const indexDate = 'idx_transactions_date';
  static const indexCategory = 'idx_transactions_category';

  static const createSql =
      '''
    CREATE TABLE IF NOT EXISTS $name (
      $columnId TEXT PRIMARY KEY,
      $columnCategoryId TEXT NOT NULL,
      $columnType TEXT NOT NULL CHECK ($columnType IN ('income', 'expense')),
      $columnAmountMinor INTEGER NOT NULL CHECK ($columnAmountMinor > 0),
      $columnNote TEXT,
      $columnDate TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnCategoryId, $columnType)
        REFERENCES categories(id, type)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    )
  ''';

  static const createDateIndexSql =
      'CREATE INDEX IF NOT EXISTS $indexDate ON $name($columnDate DESC)';

  static const createCategoryIndexSql =
      'CREATE INDEX IF NOT EXISTS $indexCategory ON $name($columnCategoryId)';
}

/// Applies the v3 transactions migration.
Future<void> createTransactionsTable(Database db) async {
  await db.execute(TransactionsTable.createSql);
  await db.execute(TransactionsTable.createDateIndexSql);
  await db.execute(TransactionsTable.createCategoryIndexSql);
}
