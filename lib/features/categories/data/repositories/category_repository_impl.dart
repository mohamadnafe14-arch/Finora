import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/error/database_error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/finance_validators.dart';
import '../../../../core/utils/id_generator.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category.dart';
import 'category_repository.dart';

/// Validating implementation of [CategoryRepository].
@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._dataSource, this._idGenerator);

  final CategoryLocalDataSource _dataSource;
  final IdGenerator _idGenerator;

  @override
  Future<List<Category>> getAll({TransactionType? type}) =>
      _guard(() => _dataSource.getAll(type: type));

  @override
  Future<Category> getById(String id) async {
    final category = await _guard(() => _dataSource.getById(id));
    if (category == null) {
      throw NotFoundFailure('Category $id does not exist.');
    }
    return category;
  }

  @override
  Future<Category> create({
    required String name,
    required TransactionType type,
  }) async {
    final now = DateTime.now().toUtc();
    final category = Category(
      id: _idGenerator.newId(),
      name: FinanceValidators.categoryName(name),
      type: type,
      createdAt: now,
      updatedAt: now,
    );
    return _guard(() => _dataSource.insert(category));
  }

  @override
  Future<Category> update({required String id, required String name}) async {
    final existing = await getById(id);
    final updated = Category(
      id: existing.id,
      name: FinanceValidators.categoryName(name),
      type: existing.type,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    return _guard(() => _dataSource.update(updated));
  }

  @override
  Future<void> delete(String id) async {
    await getById(id);
    await _guard(() => _dataSource.delete(id));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error) {
      throw DatabaseErrorMapper.map(error);
    }
  }
}
