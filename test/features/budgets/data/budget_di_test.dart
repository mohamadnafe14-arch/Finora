import 'package:finora/core/di/injection.dart';
import 'package:finora/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:finora/features/budgets/data/datasources/sqflite_budget_local_data_source.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository_impl.dart';
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

  test('budget data layer resolves from the service locator', () {
    expect(getIt<BudgetLocalDataSource>(), isA<SqfliteBudgetLocalDataSource>());
    expect(getIt<BudgetRepository>(), isA<BudgetRepositoryImpl>());
  });
}
