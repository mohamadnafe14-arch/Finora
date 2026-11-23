import 'package:finora/core/di/injection.dart';
import 'package:finora/features/transactions/presentation/cubit/transaction_form_cubit.dart';
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

  test('service locator exposes the transaction form cubit', () {
    final cubit = getIt<TransactionFormCubit>();
    addTearDown(cubit.close);

    expect(cubit, isA<TransactionFormCubit>());
    expect(cubit.state.status, isNotNull);
  });
}
