import '../models/transaction.dart';
import '../models/transaction_query.dart';

/// Local storage contract for transactions.
abstract interface class TransactionLocalDataSource {
  /// Returns transactions matching [query], newest first.
  Future<List<Transaction>> getAll({TransactionQuery? query});

  /// Returns the transaction with [id], or `null` when absent.
  Future<Transaction?> getById(String id);

  /// Inserts [transaction] and returns it.
  Future<Transaction> insert(Transaction transaction);

  /// Persists changes to [transaction] and returns it.
  Future<Transaction> update(Transaction transaction);

  /// Deletes the transaction with [id].
  Future<void> delete(String id);

  /// Sums piastres for [categoryId] within the `YYYY-MM` [period].
  Future<int> sumByCategoryAndPeriod(String categoryId, String period);
}
