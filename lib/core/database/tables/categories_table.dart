import 'package:sqflite/sqflite.dart';

/// Schema constants for the `categories` table.
abstract final class CategoriesTable {
  static const name = 'categories';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnType = 'type';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';

  static const createSql =
      '''
    CREATE TABLE IF NOT EXISTS $name (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL COLLATE NOCASE,
      $columnType TEXT NOT NULL CHECK ($columnType IN ('income', 'expense')),
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      UNIQUE ($columnName, $columnType),
      UNIQUE ($columnId, $columnType)
    )
  ''';
}

/// Applies the v2 categories migration.
Future<void> createCategoriesTable(Database db) =>
    db.execute(CategoriesTable.createSql);
