import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/error/database_error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/finance_validators.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction.dart';
import '../models/transaction_query.dart';
import 'transaction_repository.dart';

/// Validating implementation of [TransactionRepository].
@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(
    this._dataSource,
    this._categories,
    this._idGenerator,
  );

  final TransactionLocalDataSource _dataSource;
  final CategoryRepository _categories;
  final IdGenerator _idGenerator;

  @override
  Future<List<Transaction>> getAll({TransactionQuery? query}) =>
      _guard(() => _dataSource.getAll(query: query));

  @override
  Future<Transaction> getById(String id) async {
    final transaction = await _guard(() => _dataSource.getById(id));
    if (transaction == null) {
      throw NotFoundFailure('Transaction $id does not exist.');
    }
    return transaction;
  }

  @override
  Future<Transaction> create({
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  }) async {
    await _validateCategory(categoryId, type);
    final now = DateTime.now().toUtc();
    final transaction = Transaction(
      id: _idGenerator.newId(),
      categoryId: categoryId,
      type: type,
      amountMinor: FinanceValidators.amountMinor(amountMinor),
      note: _normalizeNote(note),
      date: date.toUtc(),
      createdAt: now,
      updatedAt: now,
    );
    return _guard(() => _dataSource.insert(transaction));
  }

  @override
  Future<Transaction> update({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  }) async {
    final existing = await getById(id);
    await _validateCategory(categoryId, type);
    final updated = Transaction(
      id: existing.id,
      categoryId: categoryId,
      type: type,
      amountMinor: FinanceValidators.amountMinor(amountMinor),
      note: _normalizeNote(note),
      date: date.toUtc(),
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

  @override
  Future<int> sumByCategoryAndPeriod(String categoryId, String period) =>
      _guard(() => _dataSource.sumByCategoryAndPeriod(categoryId, period));

  Future<void> _validateCategory(String id, TransactionType type) async {
    final category = await _categories.getById(id);
    FinanceValidators.transactionCategoryType(type, category.type);
  }

  String? _normalizeNote(String? note) {
    final trimmed = note?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error) {
      throw DatabaseErrorMapper.map(error);
    }
  }
}
