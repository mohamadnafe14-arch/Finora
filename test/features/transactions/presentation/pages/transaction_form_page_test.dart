import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_state.dart';
import 'package:finora/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/category_test_data.dart';
import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_test_data.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeCategoryRepository categories;
  late TransactionFormCubit cubit;

  final food = buildCategory(id: 'food', name: 'Food');
  final salary = buildCategory(
    id: 'salary',
    name: 'Salary',
    type: TransactionType.income,
  );

  setUp(() {
    categories = FakeCategoryRepository(TransactionType.expense)
      ..categories = [food, salary];
    transactions = FakeTransactionRepository();
    cubit = TransactionFormCubit(transactions, categories);
  });

  tearDown(() => cubit.close());

  Future<void> pumpPage(
    WidgetTester tester, {
    String? transactionId,
    VoidCallback? onSaved,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TransactionFormPage(
              cubit: cubit,
              transactionId: transactionId,
              onSaved: onSaved,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows loading then the create form fields', (tester) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('transaction-form-loading')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Add transaction'), findsOneWidget);
    expect(find.byKey(const Key('form-type-field')), findsOneWidget);
    expect(find.byKey(const Key('form-category-field')), findsOneWidget);
    expect(find.byKey(const Key('form-amount-field')), findsOneWidget);
    expect(find.byKey(const Key('form-date-field')), findsOneWidget);
    expect(find.byKey(const Key('form-note-field')), findsOneWidget);
    expect(find.byKey(const Key('form-save-button')), findsOneWidget);
  });

  testWidgets('saves a valid entry and notifies the caller', (tester) async {
    var savedCalls = 0;
    await pumpPage(tester, onSaved: () => savedCalls++);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('form-amount-field')), '25.50');
    await tester.tap(find.byKey(const Key('form-category-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('form-save-button')));
    await tester.pumpAndSettle();

    expect(cubit.state.status, TransactionFormStatus.success);
    expect(transactions.items.single.amountMinor, 2550);
    expect(savedCalls, 1);
  });

  testWidgets('shows field and form errors', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('form-amount-field')),
      '12.345',
    );
    await tester.tap(find.byKey(const Key('form-save-button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('positive amount'), findsWidgets);
    expect(find.text('Select a category.'), findsOneWidget);

    categories.getAllError = const StorageFailure('Categories unavailable');
    await cubit.startCreate();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('form-error')), findsOneWidget);
    expect(find.text('Categories unavailable'), findsOneWidget);
  });

  testWidgets('prefills fields when editing an existing transaction', (
    tester,
  ) async {
    transactions.items = [
      buildTransaction(
        id: 't1',
        categoryId: 'food',
        amountMinor: 1250,
        note: 'Lunch',
      ),
    ];
    await pumpPage(tester, transactionId: 't1');
    await tester.pumpAndSettle();

    expect(find.text('Edit transaction'), findsOneWidget);
    expect(
      find.text('12.50'),
      findsWidgets,
    ); // amount field plus formatted hint
    expect(find.text('Lunch'), findsWidgets);
  });

  testWidgets('type changes replace the available categories', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await cubit.typeChanged(TransactionType.income);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('form-category-field')));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsWidgets);
    expect(find.text('Food'), findsNothing);
  });
}
