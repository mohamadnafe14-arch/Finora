import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_details_cubit.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

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
      ),
    ]);
    cubit = TransactionDetailsCubit(transactions, categories);
  });

  tearDown(() => cubit.close());

  test('loads the transaction with its category name', () async {
    await cubit.load('t1');

    expect(cubit.state.status, TransactionDetailsStatus.success);
    expect(cubit.state.transaction?.id, 't1');
    expect(cubit.state.categoryName, 'Food');
    expect(cubit.state.errorMessage, isNull);
  });

  test('maps a load failure to the failure state', () async {
    transactions.getByIdError = const StorageFailure('Read failed');

    await cubit.load('t1');

    expect(cubit.state.status, TransactionDetailsStatus.failure);
    expect(cubit.state.errorMessage, 'Read failed');
  });

  test('deletes the loaded transaction', () async {
    await cubit.load('t1');

    await cubit.delete();

    expect(cubit.state.status, TransactionDetailsStatus.deleted);
    expect(transactions.deleteCalls, 1);
    expect(transactions.items, isEmpty);
  });

  test('maps a delete failure to the failure state', () async {
    await cubit.load('t1');
    transactions.deleteError = const StorageFailure('Delete failed');

    await cubit.delete();

    expect(cubit.state.status, TransactionDetailsStatus.failure);
    expect(cubit.state.errorMessage, 'Delete failed');
  });

  test('does nothing when there is no loaded transaction', () async {
    await cubit.delete();

    expect(transactions.deleteCalls, 0);
    expect(cubit.state.status, TransactionDetailsStatus.initial);
  });
}
