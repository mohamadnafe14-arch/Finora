import 'package:finora/core/utils/date_serializer.dart';
import 'package:finora/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finora/features/transactions/data/models/transaction.dart';
import 'package:finora/features/transactions/data/models/transaction_query.dart';

/// In-memory [TransactionLocalDataSource] used by repository tests.
class FakeTransactionDataSource implements TransactionLocalDataSource {
  final List<Transaction> items = <Transaction>[];
  Object? error;

  @override
  Future<List<Transaction>> getAll({TransactionQuery? query}) async {
    _throwIfConfigured();
    return List<Transaction>.of(items);
  }

  @override
  Future<Transaction?> getById(String id) async {
    _throwIfConfigured();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Transaction> insert(Transaction transaction) async {
    _throwIfConfigured();
    items.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    _throwIfConfigured();
    final index = items.indexWhere((item) => item.id == transaction.id);
    items[index] = transaction;
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    _throwIfConfigured();
    items.removeWhere((item) => item.id == id);
  }

  @override
  Future<int> sumByCategoryAndPeriod(String categoryId, String period) async {
    _throwIfConfigured();
    return items
        .where(
          (item) =>
              item.categoryId == categoryId &&
              DateSerializer.periodOf(item.date) == period,
        )
        .fold<int>(0, (sum, item) => sum + item.amountMinor);
  }

  void _throwIfConfigured() {
    final failure = error;
    if (failure != null) throw failure;
  }
}
