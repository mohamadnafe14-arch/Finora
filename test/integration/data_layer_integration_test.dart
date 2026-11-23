import 'package:finora/core/database/database_migrator.dart';
import 'package:finora/core/database/schema_migrations.dart';
import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/budgets/data/models/budget.dart';
import 'package:finora/features/transactions/data/models/transaction_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helpers.dart';
import '../helpers/repository_test_harness.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'repositories share one store and preserve cross-feature invariants',
    () async {
      final harness = RepositoryTestHarness(await openTestDatabase());
      addTearDown(harness.close);
      final food = await harness.categories.create(
        name: 'Food',
        type: TransactionType.expense,
      );
      final salary = await harness.categories.create(
        name: 'Salary',
        type: TransactionType.income,
      );
      final unused = await harness.categories.create(
        name: 'Unused',
        type: TransactionType.expense,
      );

      final expense = await harness.transactions.create(
        categoryId: food.id,
        type: TransactionType.expense,
        amountMinor: 1250,
        note: '  lunch  ',
        date: DateTime(2026, 1, 15, 12),
      );
      final income = await harness.transactions.create(
        categoryId: salary.id,
        type: TransactionType.income,
        amountMinor: 500000,
        date: DateTime(2026, 1, 1),
      );
      final budget = await harness.budgets.create(
        categoryId: food.id,
        period: '2026-01',
        amountMinor: 10000,
      );

      expect(expense.date.isUtc, isTrue);
      expect(expense.note, 'lunch');
      expect(
        await harness.transactions.sumByCategoryAndPeriod(food.id, '2026-01'),
        1250,
      );
      final incomeResults = await harness.transactions.getAll(
        query: TransactionQuery(type: TransactionType.income),
      );
      expect(incomeResults, hasLength(1));
      expect(incomeResults.single.id, income.id);
      final storedBudget = await harness.budgets.getForCategoryAndPeriod(
        food.id,
        '2026-01',
      );
      expect(storedBudget?.id, budget.id);
      expect(storedBudget?.amountMinor, budget.amountMinor);
      expect(
        harness.categories.delete(food.id),
        throwsA(isA<ConflictFailure>()),
      );
      await harness.categories.delete(unused.id);
      expect(await harness.categories.getAll(), hasLength(2));
    },
  );

  test(
    'repositories reject inconsistent or invalid writes before storage',
    () async {
      final harness = RepositoryTestHarness(await openTestDatabase());
      addTearDown(harness.close);
      final expense = await harness.categories.create(
        name: 'Food',
        type: TransactionType.expense,
      );
      final income = await harness.categories.create(
        name: 'Salary',
        type: TransactionType.income,
      );

      expect(
        harness.transactions.create(
          categoryId: income.id,
          type: TransactionType.expense,
          amountMinor: 100,
          date: DateTime.utc(2026, 1, 1),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        harness.budgets.create(
          categoryId: income.id,
          period: '2026-01',
          amountMinor: 10000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        harness.budgets.create(
          categoryId: expense.id,
          period: '2026-13',
          amountMinor: 10000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(await harness.transactions.getAll(), isEmpty);
      expect(await harness.budgets.getAll(), isEmpty);
    },
  );

  test(
    'upgraded v1 database remains usable through every repository',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await DatabaseMigrator({1: schemaMigrations[1]!}).onCreate(db);
      await DatabaseMigrator(schemaMigrations).onUpgrade(db, 1, 4);
      final harness = RepositoryTestHarness(db);
      addTearDown(harness.close);

      final category = await harness.categories.create(
        name: 'Transport',
        type: TransactionType.expense,
      );
      await harness.transactions.create(
        categoryId: category.id,
        type: TransactionType.expense,
        amountMinor: 2500,
        date: DateTime.utc(2026, 2, 10),
      );
      await harness.budgets.create(
        categoryId: category.id,
        period: '2026-02',
        amountMinor: 20000,
      );

      expect(
        await harness.transactions.sumByCategoryAndPeriod(
          category.id,
          '2026-02',
        ),
        2500,
      );
      expect(
        await harness.budgets.getForCategoryAndPeriod(category.id, '2026-02'),
        isA<Budget>(),
      );
    },
  );
}
