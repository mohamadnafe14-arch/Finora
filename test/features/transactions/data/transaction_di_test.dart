import 'package:finora/core/di/injection.dart';
import 'package:finora/features/transactions/data/datasources/sqflite_transaction_local_data_source.dart';
import 'package:finora/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository.dart';
import 'package:finora/features/transactions/data/repositories/transaction_repository_impl.dart';
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

  test('transaction data layer resolves from the service locator', () {
    expect(
      getIt<TransactionLocalDataSource>(),
      isA<SqfliteTransactionLocalDataSource>(),
    );
    expect(getIt<TransactionRepository>(), isA<TransactionRepositoryImpl>());
  });
}
