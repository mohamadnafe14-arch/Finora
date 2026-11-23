import 'package:finora/core/database/tables/categories_table.dart';
import 'package:finora/features/budgets/data/datasources/sqflite_budget_local_data_source.dart';
import 'package:finora/features/budgets/data/models/budget.dart';
import 'package:finora/features/budgets/data/models/budget_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show Database, DatabaseException;

import '../../../../helpers/database_test_helpers.dart';

void main() {
  late Database database;
  late SqfliteBudgetLocalDataSource dataSource;

  setUp(() async {
    database = await openTestDatabase();
    await _seedCategory(database, 'c1', 'expense');
    await _seedCategory(database, 'c2', 'income');
    dataSource = SqfliteBudgetLocalDataSource(TestDatabaseProvider(database));
  });

  tearDown(() async => database.close());

  test('returns an empty list before any budget is inserted', () async {
    expect(await dataSource.getAll(), isEmpty);
  });

  test('inserts and reads a budget', () async {
    final budget = _budget('b1', 'c1', '2026-01', 10000);

    await dataSource.insert(budget);

    expect(await dataSource.getById('b1'), budget);
  });

  test('finds a budget by category and period', () async {
    await dataSource.insert(_budget('b1', 'c1', '2026-01', 10000));

    expect(
      await dataSource.getForCategoryAndPeriod('c1', '2026-01'),
      isA<Budget>().having((item) => item.id, 'id', 'b1'),
    );
    expect(await dataSource.getForCategoryAndPeriod('c1', '2026-02'), isNull);
  });

  test('lists budgets newest period first', () async {
    await dataSource.insert(_budget('b1', 'c1', '2026-01', 10000));
    await dataSource.insert(_budget('b2', 'c1', '2026-03', 20000));

    final result = await dataSource.getAll();

    expect(result.map((item) => item.id), ['b2', 'b1']);
  });

  test('filters by period and category', () async {
    await dataSource.insert(_budget('b1', 'c1', '2026-01', 10000));
    await dataSource.insert(_budget('b2', 'c1', '2026-02', 20000));

    final byPeriod = await dataSource.getAll(
      query: BudgetQuery(period: '2026-02'),
    );
    final byCategory = await dataSource.getAll(
      query: BudgetQuery(categoryId: 'c1'),
    );

    expect(byPeriod.map((item) => item.id), ['b2']);
    expect(byCategory, hasLength(2));
  });

  test('updates a budget amount', () async {
    await dataSource.insert(_budget('b1', 'c1', '2026-01', 10000));

    await dataSource.update(_budget('b1', 'c1', '2026-01', 25000));

    expect((await dataSource.getById('b1'))?.amountMinor, 25000);
  });

  test('rejects a budget for an income category', () async {
    expect(
      dataSource.insert(_budget('b1', 'c2', '2026-01', 10000)),
      throwsA(isA<DatabaseException>()),
    );
  });
}

Future<void> _seedCategory(Database db, String id, String type) =>
    db.insert(CategoriesTable.name, <String, Object?>{
      CategoriesTable.columnId: id,
      CategoriesTable.columnName: id,
      CategoriesTable.columnType: type,
      CategoriesTable.columnCreatedAt: '2026-01-01T00:00:00.000Z',
      CategoriesTable.columnUpdatedAt: '2026-01-01T00:00:00.000Z',
    });

Budget _budget(String id, String categoryId, String period, int amountMinor) =>
    Budget(
      id: id,
      categoryId: categoryId,
      period: period,
      amountMinor: amountMinor,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
