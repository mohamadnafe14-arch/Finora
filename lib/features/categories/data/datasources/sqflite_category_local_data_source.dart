import 'package:injectable/injectable.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/tables/categories_table.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/date_serializer.dart';
import '../models/category.dart';
import 'category_local_data_source.dart';

/// SQLite implementation of [CategoryLocalDataSource].
@LazySingleton(as: CategoryLocalDataSource)
class SqfliteCategoryLocalDataSource implements CategoryLocalDataSource {
  const SqfliteCategoryLocalDataSource(this._provider);

  final DatabaseProvider _provider;

  @override
  Future<List<Category>> getAll({TransactionType? type}) async {
    final db = await _provider.database;
    final rows = await db.query(
      CategoriesTable.name,
      where: type == null ? null : '${CategoriesTable.columnType} = ?',
      whereArgs: type == null ? null : [type.storageValue],
      orderBy: '${CategoriesTable.columnName} ASC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<Category?> getById(String id) async {
    final db = await _provider.database;
    final rows = await db.query(
      CategoriesTable.name,
      where: '${CategoriesTable.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Category> insert(Category category) async {
    final db = await _provider.database;
    await db.insert(CategoriesTable.name, _toRow(category));
    return category;
  }

  @override
  Future<Category> update(Category category) async {
    final db = await _provider.database;
    await db.update(
      CategoriesTable.name,
      _toRow(category),
      where: '${CategoriesTable.columnId} = ?',
      whereArgs: [category.id],
    );
    return category;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _provider.database;
    await db.delete(
      CategoriesTable.name,
      where: '${CategoriesTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Category _fromRow(Map<String, Object?> row) => Category(
    id: row[CategoriesTable.columnId]! as String,
    name: row[CategoriesTable.columnName]! as String,
    type: transactionTypeFromStorage(
      row[CategoriesTable.columnType]! as String,
    ),
    createdAt: DateSerializer.parse(
      row[CategoriesTable.columnCreatedAt]! as String,
    ),
    updatedAt: DateSerializer.parse(
      row[CategoriesTable.columnUpdatedAt]! as String,
    ),
  );

  Map<String, Object?> _toRow(Category category) => {
    CategoriesTable.columnId: category.id,
    CategoriesTable.columnName: category.name,
    CategoriesTable.columnType: category.type.storageValue,
    CategoriesTable.columnCreatedAt: DateSerializer.format(category.createdAt),
    CategoriesTable.columnUpdatedAt: DateSerializer.format(category.updatedAt),
  };
}
