import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_details_cubit.dart';
import 'package:finora/features/transactions/presentation/pages/transaction_details_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/category_test_data.dart';
import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_test_data.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;
  late TransactionDetailsCubit cubit;

  setUp(() {
    categories = FakeCategoryRepository(TransactionType.expense)
      ..categories = [buildCategory(id: 'food', name: 'Food')];
    transactions = FakeTransactionRepository([
      buildTransaction(
        id: 't1',
        categoryId: 'food',
        amountMinor: 1250,
        note: 'Lunch',
        date: DateTime.utc(2026, 2, 3, 10, 30),
      ),
    ]);
    cubit = TransactionDetailsCubit(transactions, categories);
  });

  tearDown(() => cubit.close());

  Future<void> pumpPage(WidgetTester tester, {void Function()? onChanged}) {
    return tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailsPage(
          transactionId: 't1',
          cubit: cubit,
          onChanged: onChanged,
        ),
      ),
    );
  }

  testWidgets('shows the loaded transaction details', (tester) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('details-loading')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('EGP 12.50'), findsOneWidget);
    expect(find.text('Lunch'), findsWidgets);
    expect(find.byKey(const Key('edit-transaction-button')), findsOneWidget);
    expect(find.byKey(const Key('details-delete')), findsOneWidget);
  });

  testWidgets('shows a failure and retries', (tester) async {
    transactions.getByIdError = const StorageFailure('Read failed');
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Read failed'), findsOneWidget);

    transactions.getByIdError = null;
    await tester.tap(find.byKey(const Key('details-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('details-amount')), findsOneWidget);
  });

  testWidgets('confirms deletion and notifies the caller', (tester) async {
    var changes = 0;
    await pumpPage(tester, onChanged: () => changes++);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('details-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Delete transaction?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();

    expect(transactions.deleteCalls, 1);
    expect(changes, 1);
  });

  testWidgets('cancel keeps the transaction', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('details-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(transactions.deleteCalls, 0);
    expect(find.byKey(const Key('details-amount')), findsOneWidget);
  });
}
