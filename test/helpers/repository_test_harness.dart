import 'package:finora/core/database/database_provider.dart';
import 'package:finora/core/utils/id_generator.dart';
import 'package:finora/features/budgets/data/datasources/sqflite_budget_local_data_source.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:finora/features/categories/data/datasources/sqflite_category_local_data_source.dart';
import 'package:finora/features/categories/data/repositories/category_repository.dart';
import 'package:finora/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finora/features/transactions/data/datasources/sqflite_transaction_local_data_source.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:sqflite/sqflite.dart' show Database;

import 'database_test_helpers.dart';

/// Wires the production repositories to one in-memory SQLite database.
class RepositoryTestHarness {
  RepositoryTestHarness(this.database)
    : _provider = TestDatabaseProvider(database) {
    final categoriesDataSource = SqfliteCategoryLocalDataSource(_provider);
    final transactionsDataSource = SqfliteTransactionLocalDataSource(_provider);
    final budgetsDataSource = SqfliteBudgetLocalDataSource(_provider);
    const idGenerator = UuidIdGenerator();

    categories = CategoryRepositoryImpl(categoriesDataSource, idGenerator);
    transactions = TransactionRepositoryImpl(
      transactionsDataSource,
      categories,
      idGenerator,
    );
    budgets = BudgetRepositoryImpl(budgetsDataSource, categories, idGenerator);
  }

  final Database database;
  final DatabaseProvider _provider;

  late final CategoryRepository categories;
  late final TransactionRepository transactions;
  late final BudgetRepository budgets;

  Future<void> close() => database.close();
}
