import '../../../../core/enums/transaction_type.dart';
import '../models/transaction.dart';
import '../models/transaction_query.dart';

/// Application-facing operations for transactions.
abstract interface class TransactionRepository {
  /// Returns transactions matching [query], newest first.
  Future<List<Transaction>> getAll({TransactionQuery? query});

  /// Returns the transaction with [id] or throws a not-found failure.
  Future<Transaction> getById(String id);

  /// Creates a validated transaction with a fresh identifier.
  Future<Transaction> create({
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  });

  /// Replaces the mutable fields of an existing transaction.
  Future<Transaction> update({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  });

  /// Deletes a transaction.
  Future<void> delete(String id);

  /// Sums piastres for [categoryId] within the `YYYY-MM` [period].
  Future<int> sumByCategoryAndPeriod(String categoryId, String period);
}
