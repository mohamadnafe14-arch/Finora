import 'package:finora/core/database/database_provider.dart';
import 'package:finora/core/di/injection.dart';
import 'package:finora/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finora/features/categories/data/datasources/sqflite_category_local_data_source.dart';
import 'package:finora/features/categories/data/repositories/category_repository.dart';
import 'package:finora/features/categories/data/repositories/category_repository_impl.dart';
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

  test('category data layer resolves from the service locator', () {
    expect(getIt<DatabaseProvider>(), isNotNull);
    expect(
      getIt<CategoryLocalDataSource>(),
      isA<SqfliteCategoryLocalDataSource>(),
    );
    expect(getIt<CategoryRepository>(), isA<CategoryRepositoryImpl>());
  });
}
