import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../../core/error/database_error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/finance_validators.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../models/budget.dart';
import '../models/budget_query.dart';
import 'budget_repository.dart';

/// Validating implementation of [BudgetRepository].
@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl(
    this._dataSource,
    this._categories,
    this._idGenerator,
  );

  final BudgetLocalDataSource _dataSource;
  final CategoryRepository _categories;
  final IdGenerator _idGenerator;

  @override
  Future<List<Budget>> getAll({BudgetQuery? query}) async {
    final period = query?.period;
    if (period != null) FinanceValidators.period(period);
    return _guard(() => _dataSource.getAll(query: query));
  }

  @override
  Future<Budget> getById(String id) async {
    final budget = await _guard(() => _dataSource.getById(id));
    if (budget == null) {
      throw NotFoundFailure('Budget $id does not exist.');
    }
    return budget;
  }

  @override
  Future<Budget?> getForCategoryAndPeriod(
    String categoryId,
    String period,
  ) async {
    FinanceValidators.period(period);
    return _guard(
      () => _dataSource.getForCategoryAndPeriod(categoryId, period),
    );
  }

  @override
  Future<Budget> create({
    required String categoryId,
    required String period,
    required int amountMinor,
  }) async {
    final validPeriod = FinanceValidators.period(period);
    await _validateCategory(categoryId);
    final existing = await _guard(
      () => _dataSource.getForCategoryAndPeriod(categoryId, validPeriod),
    );
    if (existing != null) {
      throw const ConflictFailure(
        'A budget already exists for this category and month.',
      );
    }
    final now = DateTime.now().toUtc();
    final budget = Budget(
      id: _idGenerator.newId(),
      categoryId: categoryId,
      period: validPeriod,
      amountMinor: FinanceValidators.amountMinor(amountMinor),
      createdAt: now,
      updatedAt: now,
    );
    return _guard(() => _dataSource.insert(budget));
  }

  @override
  Future<Budget> update({required String id, required int amountMinor}) async {
    final existing = await getById(id);
    await _validateCategory(existing.categoryId);
    final updated = Budget(
      id: existing.id,
      categoryId: existing.categoryId,
      period: existing.period,
      amountMinor: FinanceValidators.amountMinor(amountMinor),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    return _guard(() => _dataSource.update(updated));
  }

  Future<void> _validateCategory(String id) async {
    final category = await _categories.getById(id);
    FinanceValidators.budgetCategoryType(category.type);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error) {
      throw DatabaseErrorMapper.map(error);
    }
  }
}
