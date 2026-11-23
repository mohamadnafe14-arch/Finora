import '../enums/transaction_type.dart';
import '../error/failures.dart';

/// Shared validation rules for financial data.
abstract final class FinanceValidators {
  static final RegExp _periodPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

  /// Returns a trimmed, non-empty category name or throws [ValidationFailure].
  static String categoryName(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      throw const ValidationFailure('Category name must not be empty.');
    }
    return name;
  }

  /// Ensures a monetary amount stored in piastres is positive.
  static int amountMinor(int value) {
    if (value <= 0) {
      throw const ValidationFailure('Amount must be greater than zero.');
    }
    return value;
  }

  /// Validates a `YYYY-MM` calendar month.
  static String period(String value) {
    if (!_periodPattern.hasMatch(value)) {
      throw const ValidationFailure('Period must use YYYY-MM format.');
    }
    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final parsed = DateTime.utc(year, month);
    if (parsed.year != year || parsed.month != month) {
      throw const ValidationFailure('Period is not a real calendar month.');
    }
    return value;
  }

  /// Ensures a transaction type matches its category type.
  static void transactionCategoryType(
    TransactionType transaction,
    TransactionType category,
  ) {
    if (transaction != category) {
      throw const ValidationFailure(
        'Transaction type must match the category type.',
      );
    }
  }

  /// Ensures budgets only reference expense categories.
  static void budgetCategoryType(TransactionType category) {
    if (category != TransactionType.expense) {
      throw const ValidationFailure(
        'Budgets can only reference expense categories.',
      );
    }
  }
}
