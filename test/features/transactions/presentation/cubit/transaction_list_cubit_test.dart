import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/core/utils/utc_date_range.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_list_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/category_test_data.dart';
import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_test_data.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;
  late TransactionListCubit cubit;

  setUp(() {
    categories = FakeCategoryRepository(TransactionType.expense)
      ..categories = [
        buildCategory(id: 'c1', name: 'Food'),
        buildCategory(id: 'c2', name: 'Salary', type: TransactionType.income),
      ];
    transactions = FakeTransactionRepository([
      buildTransaction(
        id: 'expense',
        categoryId: 'c1',
        note: 'Lunch',
        date: DateTime.utc(2026, 1, 15),
      ),
      buildTransaction(
        id: 'income',
        categoryId: 'c2',
        type: TransactionType.income,
        note: 'Salary',
        date: DateTime.utc(2026, 1, 20),
      ),
    ]);
    cubit = TransactionListCubit(transactions, categories);
  });

  tearDown(() => cubit.close());

  test('starts in the initial state', () {
    expect(cubit.state.status, TransactionListStatus.initial);
    expect(cubit.state.transactions, isEmpty);
  });

  test('loads transactions and categories', () async {
    await cubit.load();

    expect(cubit.state.status, TransactionListStatus.success);
    expect(cubit.state.transactions.map((transaction) => transaction.id), [
      'expense',
      'income',
    ]);
    expect(cubit.state.categories, hasLength(2));
  });

  test('reports empty and failure states', () async {
    transactions.items = [];

    await cubit.load();
    expect(cubit.state.status, TransactionListStatus.empty);

    transactions.getAllError = const StorageFailure('Database unavailable');
    await cubit.refresh();
    expect(cubit.state.status, TransactionListStatus.failure);
    expect(cubit.state.errorMessage, 'Database unavailable');
  });

  test('turns structural filters into a repository query', () async {
    await cubit.typeFilterChanged(TransactionType.income);

    expect(cubit.state.filter.type, TransactionType.income);
    expect(transactions.lastQuery?.type, TransactionType.income);
    expect(cubit.state.transactions.map((transaction) => transaction.id), [
      'income',
    ]);

    await cubit.categoryFilterChanged('c1');
    expect(transactions.lastQuery?.categoryId, 'c1');
  });

  test('clears an incompatible category when the type changes', () async {
    await cubit.categoryFilterChanged('c1');
    await cubit.typeFilterChanged(TransactionType.income);

    expect(cubit.state.filter.categoryId, isNull);
    expect(transactions.lastQuery?.categoryId, isNull);
  });

  test('passes converted UTC date bounds to the repository', () async {
    final range = UtcDateRange.forLocalDay(DateTime(2026, 1, 15, 23));

    await cubit.dateRangeChanged(range);

    final query = transactions.lastQuery;
    expect(query?.from, range.from);
    expect(query?.to, range.to);
    expect(query?.from?.isUtc, isTrue);
    expect(query?.to?.isUtc, isTrue);
  });

  test('searches notes and category names without re-querying', () async {
    await cubit.load();
    final callsAfterLoad = transactions.getAllCalls;

    cubit.searchChanged('lunch');
    expect(cubit.state.transactions.single.id, 'expense');

    cubit.searchChanged('FOOD');
    expect(cubit.state.transactions.single.id, 'expense');

    cubit.searchChanged('salary');
    expect(cubit.state.transactions.single.id, 'income');

    cubit.searchChanged('');
    expect(cubit.state.transactions, hasLength(2));
    expect(transactions.getAllCalls, callsAfterLoad);
  });

  test('clearFilters resets the filter and reloads', () async {
    await cubit.typeFilterChanged(TransactionType.income);

    await cubit.clearFilters();

    expect(cubit.state.filter.search, isEmpty);
    expect(cubit.state.filter.type, isNull);
    expect(cubit.state.filter.categoryId, isNull);
    expect(cubit.state.filter.from, isNull);
    expect(cubit.state.filter.to, isNull);
    expect(cubit.state.transactions, hasLength(2));
  });
}
