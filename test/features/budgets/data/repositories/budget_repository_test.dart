import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/core/utils/id_generator.dart';
import 'package:finora/features/budgets/data/models/budget.dart';
import 'package:finora/features/budgets/data/models/budget_query.dart';
import 'package:finora/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../../helpers/fake_budget_data_source.dart';
import '../../../../helpers/fake_category_repository.dart';

void main() {
  late FakeBudgetDataSource dataSource;
  late FakeCategoryRepository categories;
  late BudgetRepositoryImpl repository;

  setUp(() {
    dataSource = FakeBudgetDataSource();
    categories = FakeCategoryRepository(TransactionType.expense);
    repository = BudgetRepositoryImpl(
      dataSource,
      categories,
      const _FakeIdGenerator(),
    );
  });

  test('creates a validated budget with a generated id', () async {
    final budget = await repository.create(
      categoryId: 'c1',
      period: '2026-01',
      amountMinor: 10000,
    );

    expect(budget.id, 'generated-id');
    expect(budget.period, '2026-01');
    expect(budget.amountMinor, 10000);
    expect(budget.createdAt.isUtc, isTrue);
    expect(dataSource.items, [budget]);
  });

  test('rejects an invalid period', () async {
    expect(
      repository.create(
        categoryId: 'c1',
        period: '2026-13',
        amountMinor: 10000,
      ),
      throwsA(isA<ValidationFailure>()),
    );
    expect(dataSource.items, isEmpty);
  });

  test('rejects non-positive amounts', () async {
    expect(
      repository.create(categoryId: 'c1', period: '2026-01', amountMinor: 0),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects an income category', () async {
    categories = FakeCategoryRepository(TransactionType.income);
    repository = BudgetRepositoryImpl(
      dataSource,
      categories,
      const _FakeIdGenerator(),
    );

    expect(
      repository.create(
        categoryId: 'c1',
        period: '2026-01',
        amountMinor: 10000,
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects a duplicate category and month', () async {
    await dataSource.insert(_budget());

    expect(
      repository.create(
        categoryId: 'c1',
        period: '2026-01',
        amountMinor: 10000,
      ),
      throwsA(isA<ConflictFailure>()),
    );
  });

  test('reports a missing category as a not-found failure', () async {
    categories.missing = true;

    expect(
      repository.create(
        categoryId: 'missing',
        period: '2026-01',
        amountMinor: 10000,
      ),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('reports a missing budget as a not-found failure', () async {
    expect(repository.getById('missing'), throwsA(isA<NotFoundFailure>()));
  });

  test('maps a database error to a conflict failure', () async {
    await dataSource.insert(_budget());
    dataSource.error = _FakeDatabaseException(
      'UNIQUE constraint failed: budgets.category_id, budgets.period',
    );

    expect(
      repository.create(
        categoryId: 'c2',
        period: '2026-02',
        amountMinor: 10000,
      ),
      throwsA(isA<ConflictFailure>()),
    );
  });

  test('updates only the amount while preserving budget history', () async {
    await dataSource.insert(_budget());

    final updated = await repository.update(id: 'b1', amountMinor: 25000);

    expect(updated.id, 'b1');
    expect(updated.categoryId, 'c1');
    expect(updated.period, '2026-01');
    expect(updated.amountMinor, 25000);
    expect(updated.createdAt, _budget().createdAt);
  });

  test('finds by category and month and delegates filters', () async {
    await dataSource.insert(_budget());

    expect(
      await repository.getForCategoryAndPeriod('c1', '2026-01'),
      isA<Budget>(),
    );
    expect(
      await repository.getAll(query: BudgetQuery(period: '2026-01')),
      hasLength(1),
    );
  });
}

Budget _budget() => Budget(
  id: 'b1',
  categoryId: 'c1',
  period: '2026-01',
  amountMinor: 10000,
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
