import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/egp_amount.dart';
import '../../../categories/data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';

/// Field validation result for the transaction form.
class TransactionFormErrors {
  const TransactionFormErrors(this.amountError, this.categoryError);

  final String? amountError;
  final String? categoryError;

  bool get hasErrors => amountError != null || categoryError != null;
}

/// Persistence helper used by the transaction form ViewModel.
class TransactionFormSaver {
  const TransactionFormSaver(this._transactions);

  static const _invalidAmount =
      'Enter a positive amount with up to 2 decimals.';

  final TransactionRepository _transactions;

  TransactionFormErrors validate({
    required String amountText,
    required String? categoryId,
    required List<Category> categories,
    required TransactionType type,
  }) {
    final amountError = EgpAmount.tryParse(amountText) == null
        ? _invalidAmount
        : null;
    final mismatch =
        categoryId != null &&
        !categories.any(
          (category) => category.id == categoryId && category.type == type,
        );
    final categoryError = categoryId == null
        ? 'Select a category.'
        : mismatch
        ? 'Category does not match the transaction type.'
        : null;
    return TransactionFormErrors(amountError, categoryError);
  }

  Future<Transaction> save({
    required String? editingId,
    required String categoryId,
    required TransactionType type,
    required int amountMinor,
    required String? note,
    required DateTime date,
  }) {
    if (editingId == null) {
      return _transactions.create(
        categoryId: categoryId,
        type: type,
        amountMinor: amountMinor,
        note: note,
        date: date,
      );
    }
    return _transactions.update(
      id: editingId,
      categoryId: categoryId,
      type: type,
      amountMinor: amountMinor,
      note: note,
      date: date,
    );
  }
}
