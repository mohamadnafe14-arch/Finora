import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/utils/utc_date_range.dart';
import 'package:finora/features/categories/initialization/default_category_initializer.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_details_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_details_state.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_state.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_list_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helpers.dart';
import '../helpers/repository_test_harness.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late RepositoryTestHarness harness;
  late String foodId;
  late String salaryId;

  setUp(() async {
    harness = RepositoryTestHarness(await openTestDatabase());
    addTearDown(harness.close);
    final food = await harness.categories.create(
      name: 'Food',
      type: TransactionType.expense,
    );
    final salary = await harness.categories.create(
      name: 'Salary',
      type: TransactionType.income,
    );
    foodId = food.id;
    salaryId = salary.id;
  });

  test('supports the full create, list, edit, and delete lifecycle', () async {
    final form = TransactionFormCubit(harness.transactions, harness.categories);
    addTearDown(form.close);
    final list = TransactionListCubit(harness.transactions, harness.categories);
    addTearDown(list.close);
    final details = TransactionDetailsCubit(
      harness.transactions,
      harness.categories,
    );
    addTearDown(details.close);

    await form.startCreate();
    form.categorySelected(foodId);
    form.amountChanged('12.50');
    form.noteChanged('Lunch');
    form.dateSelected(DateTime(2026, 1, 15));
    await form.submit();

    expect(form.state.status, TransactionFormStatus.success);
    final createdId = form.state.savedTransactionId!;

    await list.load();
    expect(list.state.status, TransactionListStatus.success);
    expect(list.state.transactions, hasLength(1));
    expect(list.state.transactions.single.amountMinor, 1250);

    await form.startEdit(createdId);
    expect(form.state.amountText, '12.50');
    form.amountChanged('20.00');
    await form.submit();
    expect(form.state.status, TransactionFormStatus.success);

    await list.refresh();
    expect(list.state.transactions.single.amountMinor, 2000);

    await details.load(createdId);
    expect(details.state.status, TransactionDetailsStatus.success);
    expect(details.state.categoryName, 'Food');

    await details.delete();
    expect(details.state.status, TransactionDetailsStatus.deleted);

    await list.refresh();
    expect(list.state.status, TransactionListStatus.empty);
    expect(await harness.transactions.getAll(), isEmpty);
  });

  test('filters by type and local day while keeping EGP precision', () async {
    final form = TransactionFormCubit(harness.transactions, harness.categories);
    addTearDown(form.close);
    final list = TransactionListCubit(harness.transactions, harness.categories);
    addTearDown(list.close);

    await form.startCreate();
    form.categorySelected(foodId);
    form.amountChanged('0.05');
    form.noteChanged('Small expense');
    form.dateSelected(DateTime(2026, 3, 10, 9));
    await form.submit();

    await form.startCreate(type: TransactionType.income);
    form.categorySelected(salaryId);
    form.amountChanged('100.25');
    form.noteChanged('Payroll');
    form.dateSelected(DateTime(2026, 3, 11, 14));
    await form.submit();

    await list.load();
    expect(
      list.state.transactions.map((item) => item.amountMinor),
      containsAll([5, 10025]),
    );
    expect(list.state.transactions, hasLength(2));

    await list.typeFilterChanged(TransactionType.income);
    expect(list.state.transactions, hasLength(1));
    expect(list.state.transactions.single.note, 'Payroll');

    await list.clearFilters();
    await list.dateRangeChanged(
      UtcDateRange.forLocalDay(DateTime(2026, 3, 10)),
    );
    expect(list.state.transactions, hasLength(1));
    expect(list.state.transactions.single.note, 'Small expense');

    list.searchChanged('PAYROLL');
    expect(list.state.transactions, isEmpty);
    list.searchChanged('small');
    expect(list.state.transactions, hasLength(1));
  });

  test(
    'rejects category and type mismatches before storing anything',
    () async {
      final form = TransactionFormCubit(
        harness.transactions,
        harness.categories,
      );
      addTearDown(form.close);

      await form.startCreate(type: TransactionType.expense);
      form.categorySelected(salaryId);
      form.amountChanged('5.00');
      await form.submit();

      expect(form.state.status, TransactionFormStatus.ready);
      expect(form.state.categoryError, contains('does not match'));
      expect(await harness.transactions.getAll(), isEmpty);

      form.categorySelected(foodId);
      form.amountChanged('0.001');
      await form.submit();
      expect(form.state.status, TransactionFormStatus.ready);
      expect(form.state.amountError, contains('positive amount'));
      expect(await harness.transactions.getAll(), isEmpty);
    },
  );

  test('first-run defaults are usable by both form modes', () async {
    final initializer = DefaultCategoryInitializer(harness.categories);
    await initializer.initialize();
    await initializer.initialize();
    final form = TransactionFormCubit(harness.transactions, harness.categories);
    addTearDown(form.close);

    await form.startCreate();
    expect(form.state.categories, isNotEmpty);
    expect(
      form.state.categories.every(
        (category) => category.type == TransactionType.expense,
      ),
      isTrue,
    );
    final firstExpense = form.state.categories.first.id;

    await form.startCreate(type: TransactionType.income);
    expect(form.state.categories, isNotEmpty);
    expect(
      form.state.categories.every(
        (category) => category.type == TransactionType.income,
      ),
      isTrue,
    );
    form.categorySelected(form.state.categories.first.id);
    form.amountChanged('10.00');
    await form.submit();

    expect(form.state.status, TransactionFormStatus.success);
    expect(
      (await harness.categories.getAll()).any(
        (item) => item.id == firstExpense,
      ),
      isTrue,
    );
  });
}
