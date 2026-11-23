import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/transactions/data/models/transaction.dart';
import 'package:finora/features/transactions/data/models/transaction_query.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository.dart';

/// In-memory [TransactionRepository] for presentation tests.
class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository([List<Transaction> transactions = const []]) {
    items = List.unmodifiable(transactions);
  }

  List<Transaction> items = const [];
  int getAllCalls = 0;
  TransactionQuery? lastQuery;
  Object? getAllError;

  @override
  Future<List<Transaction>> getAll({TransactionQuery? query}) async {
    getAllCalls++;
    lastQuery = query;
    final error = getAllError;
    if (error != null) throw error;
    return items.where((transaction) => _matches(transaction, query)).toList();
  }

  bool _matches(Transaction transaction, TransactionQuery? query) {
    if (query == null) return true;
    if (query.type != null && transaction.type != query.type) return false;
    if (query.categoryId != null &&
        transaction.categoryId != query.categoryId) {
      return false;
    }
    if (query.from != null && transaction.date.isBefore(query.from!)) {
      return false;
    }
    if (query.to != null && transaction.date.isAfter(query.to!)) return false;
    return true;
  }

  @override
  Future<Transaction> getById(String id) =>
      throw UnimplementedError('getById is not needed by this test.');

  @override
  Future<Transaction> create({
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  }) => throw UnimplementedError('create is not needed by this test.');

  @override
  Future<Transaction> update({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  }) => throw UnimplementedError('update is not needed by this test.');

  @override
  Future<void> delete(String id) =>
      throw UnimplementedError('delete is not needed by this test.');

  @override
  Future<int> sumByCategoryAndPeriod(String categoryId, String period) =>
      throw UnimplementedError('sum is not needed by this test.');
}
