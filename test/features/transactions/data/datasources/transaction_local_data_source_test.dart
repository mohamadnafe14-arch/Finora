import 'package:finora/core/database/tables/categories_table.dart';
import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/transactions/data/datasources/sqflite_transaction_local_data_source.dart';
import 'package:finora/features/transactions/data/models/transaction.dart';
import 'package:finora/features/transactions/data/models/transaction_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show Database, DatabaseException;

import '../../../../helpers/database_test_helpers.dart';

void main() {
  late Database database;
  late SqfliteTransactionLocalDataSource dataSource;

  setUp(() async {
    database = await openTestDatabase();
    await _seedCategory(database, 'c1', 'expense');
    await _seedCategory(database, 'c2', 'income');
    dataSource = SqfliteTransactionLocalDataSource(
      TestDatabaseProvider(database),
    );
  });

  tearDown(() async => database.close());

  test('returns an empty list before any transaction is inserted', () async {
    expect(await dataSource.getAll(), isEmpty);
  });

  test('inserts and reads a transaction', () async {
    final transaction = _transaction('t1', 'c1', 1250);

    await dataSource.insert(transaction);

    expect(await dataSource.getById('t1'), transaction);
  });

  test('lists transactions newest first', () async {
    await dataSource.insert(
      _transaction('t1', 'c1', 100, date: DateTime.utc(2026, 1, 1)),
    );
    await dataSource.insert(
      _transaction('t2', 'c1', 200, date: DateTime.utc(2026, 2, 1)),
    );

    final result = await dataSource.getAll();

    expect(result.map((item) => item.id), ['t2', 't1']);
  });

  test('filters by type, category and inclusive date range', () async {
    await dataSource.insert(
      _transaction('t1', 'c1', 100, date: DateTime.utc(2026, 1, 10)),
    );
    await dataSource.insert(
      _transaction('t2', 'c1', 200, date: DateTime.utc(2026, 3, 10)),
    );
    await dataSource.insert(
      _transaction('t3', 'c2', 300, type: TransactionType.income),
    );

    final byType = await dataSource.getAll(
      query: TransactionQuery(type: TransactionType.expense),
    );
    final byCategory = await dataSource.getAll(
      query: TransactionQuery(categoryId: 'c1'),
    );
    final byDate = await dataSource.getAll(
      query: TransactionQuery(
        from: DateTime.utc(2026, 2, 1),
        to: DateTime.utc(2026, 3, 31),
      ),
    );

    expect(byType.map((item) => item.id), ['t2', 't1']);
    expect(byCategory, hasLength(2));
    expect(byDate.map((item) => item.id), ['t2']);
  });

  test('updates and deletes a transaction', () async {
    await dataSource.insert(_transaction('t1', 'c1', 100));

    await dataSource.update(_transaction('t1', 'c1', 250, note: 'adjusted'));
    expect((await dataSource.getById('t1'))?.amountMinor, 250);

    await dataSource.delete('t1');
    expect(await dataSource.getById('t1'), isNull);
  });

  test('sums piastres for a category and month', () async {
    await dataSource.insert(
      _transaction('t1', 'c1', 100, date: DateTime.utc(2026, 1, 5)),
    );
    await dataSource.insert(
      _transaction('t2', 'c1', 250, date: DateTime.utc(2026, 1, 25)),
    );
    await dataSource.insert(
      _transaction('t3', 'c1', 999, date: DateTime.utc(2026, 2, 1)),
    );

    expect(await dataSource.sumByCategoryAndPeriod('c1', '2026-01'), 350);
  });

  test(
    'rejects a transaction whose type does not match the category',
    () async {
      expect(
        dataSource.insert(
          _transaction('t1', 'c1', 100, type: TransactionType.income),
        ),
        throwsA(isA<DatabaseException>()),
      );
    },
  );
}

Future<void> _seedCategory(Database db, String id, String type) =>
    db.insert(CategoriesTable.name, <String, Object?>{
      CategoriesTable.columnId: id,
      CategoriesTable.columnName: id,
      CategoriesTable.columnType: type,
      CategoriesTable.columnCreatedAt: '2026-01-01T00:00:00.000Z',
      CategoriesTable.columnUpdatedAt: '2026-01-01T00:00:00.000Z',
    });

Transaction _transaction(
  String id,
  String categoryId,
  int amountMinor, {
  TransactionType type = TransactionType.expense,
  String? note,
  DateTime? date,
}) => Transaction(
  id: id,
  categoryId: categoryId,
  type: type,
  amountMinor: amountMinor,
  note: note,
  date: date ?? DateTime.utc(2026, 1, 15),
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);
