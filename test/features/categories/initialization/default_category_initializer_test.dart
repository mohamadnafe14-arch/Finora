import 'package:finora/core/di/injection.dart';
import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/categories/initialization/default_categories.dart';
import 'package:finora/features/categories/initialization/default_category_initializer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/fake_category_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  test('defines first-run income and expense categories', () {
    final income = DefaultCategories.seeds.where(
      (seed) => seed.type == TransactionType.income,
    );
    final expense = DefaultCategories.seeds.where(
      (seed) => seed.type == TransactionType.expense,
    );

    expect(income, hasLength(3));
    expect(expense, hasLength(7));
  });

  test('delegates defaults without updating or deleting categories', () async {
    final repository = FakeCategoryRepository(TransactionType.expense);

    await DefaultCategoryInitializer(repository).initialize();

    expect(repository.initializeCalls, 1);
    expect(repository.initializedSeeds, DefaultCategories.seeds);
    expect(repository.updateCalls, 0);
    expect(repository.deleteCalls, 0);
  });

  test('resolves from the service locator', () {
    expect(
      getIt<DefaultCategoryInitializer>(),
      isA<DefaultCategoryInitializer>(),
    );
  });
}
