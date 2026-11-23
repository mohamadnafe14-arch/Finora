import 'package:finora/core/enums/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('storage value is lowercase enum name', () {
    expect(TransactionType.income.storageValue, 'income');
    expect(TransactionType.expense.storageValue, 'expense');
  });

  test('parses stored values case-insensitively', () {
    expect(transactionTypeFromStorage('INCOME'), TransactionType.income);
    expect(transactionTypeFromStorage('expense'), TransactionType.expense);
  });

  test('rejects unknown stored values', () {
    expect(() => transactionTypeFromStorage('transfer'), throwsFormatException);
  });
}
