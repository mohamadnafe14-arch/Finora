import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/core/utils/id_generator.dart';
import 'package:finora/features/categories/data/datasources/sqflite_category_local_data_source.dart';
import 'package:finora/features/categories/data/models/category_seed.dart';
import 'package:finora/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finora/features/categories/initialization/default_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../helpers/database_test_helpers.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late CategoryRepositoryImpl repository;

  setUp(() async {
    final db = await openTestDatabase();
    addTearDown(db.close);
    repository = CategoryRepositoryImpl(
      SqfliteCategoryLocalDataSource(TestDatabaseProvider(db)),
      const UuidIdGenerator(),
    );
  });

  test('seeds all defaults into an empty store', () async {
    await repository.initializeDefaults(DefaultCategories.seeds);

    final categories = await repository.getAll();
    expect(categories, hasLength(DefaultCategories.seeds.length));
    expect(
      categories.map((category) => category.name).toSet(),
      DefaultCategories.seeds.map((seed) => seed.name).toSet(),
    );
  });

  test('does not write when any category already exists', () async {
    final userCategory = await repository.create(
      name: 'My Category',
      type: TransactionType.expense,
    );

    await repository.initializeDefaults(DefaultCategories.seeds);

    final categories = await repository.getAll();
    expect(categories, hasLength(1));
    expect(categories.single.id, userCategory.id);
    expect(categories.single.name, userCategory.name);
    expect(categories.single.type, userCategory.type);
  });

  test('repeated initialization does not duplicate categories', () async {
    await repository.initializeDefaults(DefaultCategories.seeds);
    await repository.initializeDefaults(DefaultCategories.seeds);

    expect(
      await repository.getAll(),
      hasLength(DefaultCategories.seeds.length),
    );
  });

  test('rolls back every insert when one default insert fails', () async {
    const conflicting = [
      CategorySeed(name: 'First', type: TransactionType.expense),
      CategorySeed(name: 'first', type: TransactionType.expense),
    ];

    await expectLater(
      repository.initializeDefaults(conflicting),
      throwsA(isA<ConflictFailure>()),
    );
    expect(await repository.getAll(), isEmpty);
  });
}
