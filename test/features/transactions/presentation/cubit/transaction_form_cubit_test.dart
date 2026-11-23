import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_state.dart';
import 'package:finora/features/transactions/presentation/models/transaction_form_mode.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('startCreate', () {
    test('loads categories matching the type and becomes ready', () async {
      await cubit.startCreate();

      expect(cubit.state.status, TransactionFormStatus.ready);
      expect(cubit.state.mode, TransactionFormMode.create);
      expect(cubit.state.type, TransactionType.expense);
      expect(cubit.state.categories, [food]);
      expect(cubit.state.date.isUtc, isTrue);
    });

    test('maps a category loading failure to the failure state', () async {
      categories.getAllError = const StorageFailure('Categories unavailable');

      await cubit.startCreate(type: TransactionType.income);

      expect(cubit.state.status, TransactionFormStatus.failure);
      expect(cubit.state.formError, 'Categories unavailable');
    });
  });

  group('startEdit', () {
    test('populates the form from an existing transaction', () async {
      transactions.items = [
        buildTransaction(
          id: 't1',
          categoryId: 'food',
          amountMinor: 1250,
          note: 'Lunch',
          date: DateTime.utc(2026, 2, 3, 10, 30),
        ),
      ];

      await cubit.startEdit('t1');

      expect(cubit.state.status, TransactionFormStatus.ready);
      expect(cubit.state.mode, TransactionFormMode.edit);
      expect(cubit.state.editingId, 't1');
      expect(cubit.state.categoryId, 'food');
      expect(cubit.state.amountText, '12.50');
      expect(cubit.state.note, 'Lunch');
      expect(cubit.state.date, DateTime.utc(2026, 2, 3, 10, 30));
      expect(cubit.state.categories, [food]);
    });

    test('maps a load failure to the failure state', () async {
      transactions.getByIdError = const StorageFailure('Read failed');

      await cubit.startEdit('missing');

      expect(cubit.state.status, TransactionFormStatus.failure);
      expect(cubit.state.formError, 'Read failed');
    });
  });

  group('field changes', () {
    setUp(() async => cubit.startCreate());

    test('typeChanged clears the category and reloads categories', () async {
      cubit.categorySelected('food');

      await cubit.typeChanged(TransactionType.income);

      expect(cubit.state.type, TransactionType.income);
      expect(cubit.state.categoryId, isNull);
      expect(cubit.state.categories, [salary]);
    });

    test('amountChanged parses valid input and flags invalid input', () {
      cubit.amountChanged('12.50');
      expect(cubit.state.amountError, isNull);

      cubit.amountChanged('12.345');
      expect(cubit.state.amountError, contains('positive amount'));
    });

    test('note and date changes keep the form editable', () {
      cubit.noteChanged('  Dinner  ');
      cubit.dateSelected(DateTime(2026, 3, 4, 20));

      expect(cubit.state.note, '  Dinner  ');
      expect(cubit.state.date.isUtc, isTrue);
      expect(cubit.state.status, TransactionFormStatus.ready);
    });
  });

  group('submit', () {
    setUp(() async {
      await cubit.startCreate();
      cubit.categorySelected('food');
      cubit.amountChanged('12.50');
      cubit.noteChanged('Lunch');
    });

    test('creates a transaction with integer piastres and UTC date', () async {
      final date = DateTime(2026, 5, 6, 19, 45);
      cubit.dateSelected(date);

      await cubit.submit();

      expect(cubit.state.status, TransactionFormStatus.success);
      expect(cubit.state.savedTransactionId, 'created-1');
      expect(transactions.createCalls, 1);
      expect(transactions.items.single.amountMinor, 1250);
      expect(transactions.items.single.type, TransactionType.expense);
      expect(transactions.items.single.note, 'Lunch');
      expect(transactions.items.single.date.isUtc, isTrue);
      expect(transactions.items.single.date, date.toUtc());
    });

    test('updates instead of creating while editing', () async {
      transactions.items = [
        buildTransaction(id: 't1', categoryId: 'food', amountMinor: 100),
      ];
      await cubit.startEdit('t1');
      cubit.amountChanged('20.00');

      await cubit.submit();

      expect(cubit.state.status, TransactionFormStatus.success);
      expect(transactions.updateCalls, 1);
      expect(transactions.createCalls, 0);
      expect(transactions.items.single.amountMinor, 2000);
    });

    test('rejects an invalid amount before touching storage', () async {
      cubit.amountChanged('abc');

      await cubit.submit();

      expect(cubit.state.status, TransactionFormStatus.ready);
      expect(cubit.state.amountError, contains('positive amount'));
      expect(transactions.createCalls, 0);
    });

    test('rejects a missing or mismatched category', () async {
      cubit.categorySelected('salary');
      await cubit.submit();
      expect(cubit.state.categoryError, contains('does not match'));
      expect(transactions.createCalls, 0);

      await cubit.startCreate();
      await cubit.submit();
      expect(cubit.state.categoryError, 'Select a category.');
      expect(transactions.createCalls, 0);
    });

    test('maps a repository failure to the failure state', () async {
      transactions.createError = const StorageFailure('Write failed');

      await cubit.submit();

      expect(cubit.state.status, TransactionFormStatus.failure);
      expect(cubit.state.formError, 'Write failed');
    });
  });
}
