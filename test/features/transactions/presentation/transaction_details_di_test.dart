import 'package:finora/core/di/injection.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_details_cubit.dart';
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

  test('service locator exposes the transaction details cubit', () {
    final cubit = getIt<TransactionDetailsCubit>();
    addTearDown(cubit.close);

    expect(cubit, isA<TransactionDetailsCubit>());
    expect(cubit.state.status, isNotNull);
  });
}
