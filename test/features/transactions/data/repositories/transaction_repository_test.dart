import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/core/utils/id_generator.dart';
import 'package:finora/features/transactions/data/models/transaction.dart';
import 'package:finora/features/transactions/data/models/transaction_query.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/fake_transaction_data_source.dart';

void main() {
  late FakeTransactionDataSource dataSource;
  late FakeCategoryRepository categories;
  late TransactionRepositoryImpl repository;

  setUp(() {
    dataSource = FakeTransactionDataSource();
    categories = FakeCategoryRepository(TransactionType.expense);
    repository = TransactionRepositoryImpl(
      dataSource,
      categories,
      const _FakeIdGenerator(),
    );
  });

  test('creates a validated transaction with generated id', () async {
    final transaction = await repository.create(
      categoryId: 'c1',
      type: TransactionType.expense,
      amountMinor: 1550,
      note: '  lunch  ',
      date: DateTime(2026, 1, 15, 10),
    );

    expect(transaction.id, 'generated-id');
    expect(transaction.amountMinor, 1550);
    expect(transaction.note, 'lunch');
    expect(transaction.date.isUtc, isTrue);
    expect(dataSource.items, [transaction]);
  });

  test('rejects non-positive amounts', () async {
    expect(
      repository.create(
        categoryId: 'c1',
        type: TransactionType.expense,
        amountMinor: 0,
        date: DateTime.utc(2026, 1, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    expect(dataSource.items, isEmpty);
  });

  test('rejects a type that does not match the category', () async {
    expect(
      repository.create(
        categoryId: 'c1',
        type: TransactionType.income,
        amountMinor: 100,
        date: DateTime.utc(2026, 1, 1),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('reports a missing category as a not-found failure', () async {
    categories.missing = true;

    expect(
      repository.create(
        categoryId: 'missing',
        type: TransactionType.expense,
        amountMinor: 100,
        date: DateTime.utc(2026, 1, 1),
      ),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('reports a missing transaction as a not-found failure', () async {
    expect(repository.getById('missing'), throwsA(isA<NotFoundFailure>()));
  });

  test('maps a database error to a conflict failure', () async {
    await dataSource.insert(_transaction());
    dataSource.error = _FakeDatabaseException('FOREIGN KEY constraint failed');

    expect(repository.delete('t1'), throwsA(isA<ConflictFailure>()));
  });

  test('updates while preserving creation time', () async {
    await dataSource.insert(_transaction());

    final updated = await repository.update(
      id: 't1',
      categoryId: 'c1',
      type: TransactionType.expense,
      amountMinor: 900,
      date: DateTime.utc(2026, 2, 1),
    );

    expect(updated.amountMinor, 900);
    expect(updated.createdAt, _transaction().createdAt);
    expect(updated.note, isNull);
  });

  test('deletes an existing transaction', () async {
    await dataSource.insert(_transaction());

    await repository.delete('t1');

    expect(dataSource.items, isEmpty);
  });

  test('delegates filters and period sums', () async {
    final query = TransactionQuery(categoryId: 'c1');
    await dataSource.insert(_transaction());

    expect(await repository.getAll(query: query), hasLength(1));
    expect(await repository.sumByCategoryAndPeriod('c1', '2026-01'), 100);
  });
}

Transaction _transaction() => Transaction(
  id: 't1',
  categoryId: 'c1',
  type: TransactionType.expense,
  amountMinor: 100,
  note: 'old',
  date: DateTime.utc(2026, 1, 15),
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

class _FakeIdGenerator implements IdGenerator {
  const _FakeIdGenerator();

  @override
  String newId() => 'generated-id';
}

class _FakeDatabaseException extends DatabaseException {
  _FakeDatabaseException(super.message);

  @override
  int? getResultCode() => null;

  @override
  Object? get result => null;
}
