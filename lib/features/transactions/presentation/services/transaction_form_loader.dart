import '../../../../core/enums/transaction_type.dart';
import '../../../categories/data/models/category.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';

/// Data needed to populate the form when editing an existing transaction.
class TransactionFormEditData {
  const TransactionFormEditData(this.transaction, this.categories);

  final Transaction transaction;
  final List<Category> categories;
}

/// Read helper used by the transaction form ViewModel.
class TransactionFormLoader {
  const TransactionFormLoader(this._transactions, this._categories);

  final TransactionRepository _transactions;
  final CategoryRepository _categories;

  /// Loads categories matching [type].
  Future<List<Category>> categories(TransactionType type) =>
      _categories.getAll(type: type);

  /// Loads a transaction and the categories matching its type.
  Future<TransactionFormEditData> edit(String id) async {
    final transaction = await _transactions.getById(id);
    final categories = await _categories.getAll(type: transaction.type);
    return TransactionFormEditData(transaction, categories);
  }
}
