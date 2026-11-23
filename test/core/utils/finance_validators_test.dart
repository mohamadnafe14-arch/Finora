import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/core/utils/finance_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('categoryName', () {
    test('trims valid names', () {
      expect(FinanceValidators.categoryName('  Groceries  '), 'Groceries');
    });

    test('rejects empty and whitespace-only names', () {
      expect(
        () => FinanceValidators.categoryName('   '),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('amountMinor', () {
    test('accepts positive piastre amounts', () {
      expect(FinanceValidators.amountMinor(1), 1);
      expect(FinanceValidators.amountMinor(1550), 1550);
    });

    test('rejects zero and negative amounts', () {
      expect(
        () => FinanceValidators.amountMinor(0),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => FinanceValidators.amountMinor(-5),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('period', () {
    test('accepts real calendar months', () {
      expect(FinanceValidators.period('2026-01'), '2026-01');
      expect(FinanceValidators.period('2024-12'), '2024-12');
    });

    test('rejects malformed strings and impossible months', () {
      for (final value in [
        '2026-1',
        '2026/01',
        '2026-13',
        '2026-00',
        'abcd-01',
      ]) {
        expect(
          () => FinanceValidators.period(value),
          throwsA(isA<ValidationFailure>()),
          reason: value,
        );
      }
    });
  });

  group('type consistency', () {
    test('accepts matching transaction and category types', () {
      expect(
        () => FinanceValidators.transactionCategoryType(
          TransactionType.expense,
          TransactionType.expense,
        ),
        returnsNormally,
      );
    });

    test('rejects mismatched transaction and category types', () {
      expect(
        () => FinanceValidators.transactionCategoryType(
          TransactionType.income,
          TransactionType.expense,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('rejects income categories for budgets', () {
      expect(
        () => FinanceValidators.budgetCategoryType(TransactionType.income),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => FinanceValidators.budgetCategoryType(TransactionType.expense),
        returnsNormally,
      );
    });
  });
}
