import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/categories/data/datasources/sqflite_category_local_data_source.dart';
import 'package:finora/features/categories/data/models/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../helpers/database_test_helpers.dart';

void main() {
  late Database database;
  late SqfliteCategoryLocalDataSource dataSource;

  setUp(() async {
    database = await openTestDatabase();
    dataSource = SqfliteCategoryLocalDataSource(TestDatabaseProvider(database));
  });

  tearDown(() async => database.close());

  test('returns an empty list before any category is inserted', () async {
    expect(await dataSource.getAll(), isEmpty);
  });

  test('inserts, reads and lists categories', () async {
    final category = _category('1', 'Groceries', TransactionType.expense);

    await dataSource.insert(category);

    expect(await dataSource.getById('1'), category);
    expect(await dataSource.getAll(), [category]);
  });

  test('filters categories by type', () async {
    await dataSource.insert(
      _category('1', 'Groceries', TransactionType.expense),
    );
    await dataSource.insert(_category('2', 'Salary', TransactionType.income));

    final expenses = await dataSource.getAll(type: TransactionType.expense);

    expect(expenses.map((item) => item.name), ['Groceries']);
  });

  test('updates a category while preserving its identifier', () async {
    final category = _category('1', 'Groceries', TransactionType.expense);
    await dataSource.insert(category);

    final updated = _category('1', 'Food', TransactionType.expense);
    await dataSource.update(updated);

    expect(await dataSource.getById('1'), updated);
  });

  test('deletes a category', () async {
    await dataSource.insert(
      _category('1', 'Groceries', TransactionType.expense),
    );

    await dataSource.delete('1');

    expect(await dataSource.getById('1'), isNull);
  });

  test('rejects duplicate names of the same type', () async {
    await dataSource.insert(
      _category('1', 'Groceries', TransactionType.expense),
    );

    expect(
      dataSource.insert(_category('2', 'groceries', TransactionType.expense)),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('allows the same name for income and expense categories', () async {
    await dataSource.insert(_category('1', 'Other', TransactionType.expense));

    await dataSource.insert(_category('2', 'Other', TransactionType.income));

    expect(await dataSource.getAll(), hasLength(2));
  });
}

Category _category(String id, String name, TransactionType type) => Category(
  id: id,
  name: name,
  type: type,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);
