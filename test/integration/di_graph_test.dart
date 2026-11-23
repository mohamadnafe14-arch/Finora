import 'package:finora/core/di/injection.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:finora/features/categories/data/repositories/category_repository.dart';
import 'package:finora/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  test('service locator exposes the complete data layer', () {
    expect(getIt<CategoryRepository>(), isA<CategoryRepositoryImpl>());
    expect(getIt<TransactionRepository>(), isA<TransactionRepositoryImpl>());
    expect(getIt<BudgetRepository>(), isA<BudgetRepositoryImpl>());
  });
}
