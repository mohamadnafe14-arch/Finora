import 'package:finora/core/di/injection.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  test('transaction list cubit resolves from the service locator', () {
    expect(getIt<TransactionListCubit>(), isA<TransactionListCubit>());
  });
}
