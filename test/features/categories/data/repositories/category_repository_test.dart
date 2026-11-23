import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/core/utils/id_generator.dart';
import 'package:finora/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finora/features/categories/data/models/category.dart';
import 'package:finora/features/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  late FakeCategoryDataSource dataSource;
  late CategoryRepositoryImpl repository;

  setUp(() {
    dataSource = FakeCategoryDataSource();
    repository = CategoryRepositoryImpl(dataSource, const _FakeIdGenerator());
  });

  test('creates a validated category with a generated id', () async {
    final category = await repository.create(
      name: '  Groceries  ',
      type: TransactionType.expense,
    );

    expect(category.id, 'generated-id');
    expect(category.name, 'Groceries');
    expect(category.createdAt.isUtc, isTrue);
    expect(dataSource.items, [category]);
  });

  test('rejects a blank category name without writing', () async {
    expect(
      repository.create(name: '   ', type: TransactionType.expense),
      throwsA(isA<ValidationFailure>()),
    );
    expect(dataSource.items, isEmpty);
  });

  test('reports a missing category as a not-found failure', () async {
    expect(repository.getById('missing'), throwsA(isA<NotFoundFailure>()));
  });

  test('maps a unique constraint error to a conflict failure', () async {
    dataSource.error = _FakeDatabaseException(
      'UNIQUE constraint failed: categories.name, categories.type',
    );

    expect(
      repository.create(name: 'Groceries', type: TransactionType.expense),
      throwsA(isA<ConflictFailure>()),
    );
  });

  test('maps a foreign key error to a conflict failure', () async {
    await dataSource.insert(_category());
    dataSource.error = _FakeDatabaseException('FOREIGN KEY constraint failed');

    expect(repository.delete('1'), throwsA(isA<ConflictFailure>()));
  });

  test('renames a category without changing its type', () async {
    await dataSource.insert(_category());

    final updated = await repository.update(id: '1', name: 'Food');

    expect(updated.name, 'Food');
    expect(updated.type, TransactionType.expense);
    expect(updated.createdAt, _category().createdAt);
  });

  test('rejects a blank rename', () async {
    await dataSource.insert(_category());

    expect(
      repository.update(id: '1', name: ' '),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('deletes an existing category', () async {
    await dataSource.insert(_category());

    await repository.delete('1');

    expect(dataSource.items, isEmpty);
  });

  test('rejects deleting a missing category', () async {
    expect(repository.delete('missing'), throwsA(isA<NotFoundFailure>()));
  });
}

Category _category() => Category(
  id: '1',
  name: 'Groceries',
  type: TransactionType.expense,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

class _FakeIdGenerator implements IdGenerator {
  const _FakeIdGenerator();

  @override
  String newId() => 'generated-id';
}

class FakeCategoryDataSource implements CategoryLocalDataSource {
  final List<Category> items = <Category>[];
  Object? error;

  @override
  Future<List<Category>> getAll({TransactionType? type}) async {
    _throwIfConfigured();
    return items.where((item) => type == null || item.type == type).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    _throwIfConfigured();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Category> insert(Category category) async {
    _throwIfConfigured();
    items.add(category);
    return category;
  }

  @override
  Future<Category> update(Category category) async {
    _throwIfConfigured();
    final index = items.indexWhere((item) => item.id == category.id);
    items[index] = category;
    return category;
  }

  @override
  Future<void> delete(String id) async {
    _throwIfConfigured();
    items.removeWhere((item) => item.id == id);
  }

  void _throwIfConfigured() {
    final failure = error;
    if (failure != null) throw failure;
  }
}

class _FakeDatabaseException extends DatabaseException {
  _FakeDatabaseException(super.message);

  @override
  int? getResultCode() => null;

  @override
  Object? get result => null;
}
