import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/transactions/data/models/transaction.dart';
import 'package:finora/features/transactions/data/models/transaction_query.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository.dart';

/// In-memory [TransactionRepository] for presentation tests.
class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository([List<Transaction> transactions = const []]) {
    items = List.of(transactions);
  }

  List<Transaction> items = const [];
  int getAllCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  TransactionQuery? lastQuery;
  Object? getAllError;
  Object? getByIdError;
  Object? createError;
  Object? updateError;

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
  Future<Transaction> getById(String id) async {
    final error = getByIdError;
    if (error != null) throw error;
    return items.firstWhere((transaction) => transaction.id == id);
  }

  @override
  Future<Transaction> create({
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    String? note,
    required DateTime date,
  }) async {
    createCalls++;
    final error = createError;
    if (error != null) throw error;
    final now = DateTime.now().toUtc();
    final transaction = Transaction(
      id: 'created-$createCalls',
      categoryId: categoryId,
      type: type,
      amountMinor: amountMinor,
      note: note,
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    items.add(transaction);
    return transaction;
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
    updateCalls++;
    final error = updateError;
    if (error != null) throw error;
    final index = items.indexWhere((transaction) => transaction.id == id);
    if (index == -1) throw StateError('Transaction not found: $id');
    final current = items[index];
    final updated = Transaction(
      id: id,
      categoryId: categoryId,
      type: type,
      amountMinor: amountMinor,
      note: note,
      date: date,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) =>
      throw UnimplementedError('delete is not needed by this test.');

  @override
  Future<int> sumByCategoryAndPeriod(String categoryId, String period) =>
      throw UnimplementedError('sum is not needed by this test.');
}
