import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_list_cubit.dart';
import 'package:finora/features/transactions/presentation/pages/transactions_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
        buildCategory(id: 'food', name: 'Food'),
        buildCategory(
          id: 'salary',
          name: 'Salary',
          type: TransactionType.income,
        ),
      ];
    transactions = FakeTransactionRepository([
      buildTransaction(
        id: 'lunch',
        categoryId: 'food',
        amountMinor: 1250,
        note: 'Lunch',
        date: DateTime.utc(2026, 1, 15),
      ),
      buildTransaction(
        id: 'pay',
        categoryId: 'salary',
        type: TransactionType.income,
        amountMinor: 500000,
        note: 'Payroll',
        date: DateTime.utc(2026, 1, 20),
      ),
    ]);
    cubit = TransactionListCubit(transactions, categories);
  });

  tearDown(() => cubit.close());

  Future<void> pumpPage(WidgetTester tester) =>
      tester.pumpWidget(MaterialApp(home: TransactionsPage(cubit: cubit)));

  testWidgets('shows loading then the populated history', (tester) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('transaction-loading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('EGP 12.50'), findsOneWidget);
    expect(find.text('EGP 5000.00'), findsOneWidget);
  });

  testWidgets('shows the empty state', (tester) async {
    transactions.items = [];

    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('transaction-empty')), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('shows an error and retries successfully', (tester) async {
    transactions.getAllError = const StorageFailure('Database unavailable');

    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Database unavailable'), findsOneWidget);
    expect(find.byKey(const Key('transaction-retry')), findsOneWidget);

    transactions.getAllError = null;
    await tester.tap(find.byKey(const Key('transaction-retry')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('searches and clears without reloading from storage', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 100));
    final callsAfterLoad = transactions.getAllCalls;

    await tester.enterText(
      find.byKey(const Key('transaction-search-field')),
      'lunch',
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(transactions.getAllCalls, callsAfterLoad);

    await tester.tap(find.byKey(const Key('transaction-clear-filters')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });
}
