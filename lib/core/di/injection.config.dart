// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:finora/app/router/app_router.dart' as _i559;
import 'package:finora/core/config/app_config.dart' as _i870;
import 'package:finora/core/database/app_database.dart' as _i955;
import 'package:finora/core/database/database_provider.dart' as _i982;
import 'package:finora/core/di/database_module.dart' as _i878;
import 'package:finora/core/utils/id_generator.dart' as _i26;
import 'package:finora/features/budgets/data/datasources/budget_local_data_source.dart'
    as _i947;
import 'package:finora/features/budgets/data/datasources/sqflite_budget_local_data_source.dart'
    as _i759;
import 'package:finora/features/budgets/data/repositories/budget_repository.dart'
    as _i683;
import 'package:finora/features/budgets/data/repositories/budget_repository_impl.dart'
    as _i1016;
import 'package:finora/features/categories/data/datasources/category_local_data_source.dart'
    as _i506;
import 'package:finora/features/categories/data/datasources/sqflite_category_local_data_source.dart'
    as _i833;
import 'package:finora/features/categories/data/repositories/category_repository.dart'
    as _i939;
import 'package:finora/features/categories/data/repositories/category_repository_impl.dart'
    as _i929;
import 'package:finora/features/categories/initialization/default_category_initializer.dart'
    as _i561;
import 'package:finora/features/home/presentation/cubit/home_cubit.dart'
    as _i808;
import 'package:finora/features/transactions/data/datasources/sqflite_transaction_local_data_source.dart'
    as _i242;
import 'package:finora/features/transactions/data/datasources/transaction_local_data_source.dart'
    as _i950;
import 'package:finora/features/transactions/data/repositories/transaction_repository.dart'
    as _i530;
import 'package:finora/features/transactions/data/repositories/transaction_repository_impl.dart'
    as _i251;
import 'package:finora/features/transactions/presentation/cubit/transaction_form_cubit.dart'
    as _i484;
import 'package:finora/features/transactions/presentation/cubit/transaction_list_cubit.dart'
    as _i970;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i559.AppRouter>(() => _i559.AppRouter());
    gh.lazySingleton<_i870.AppConfig>(() => _i870.AppConfig());
    gh.lazySingleton<_i779.DatabaseFactory>(
      () => databaseModule.databaseFactory,
    );
    gh.factory<_i808.HomeCubit>(() => _i808.HomeCubit(gh<_i870.AppConfig>()));
    gh.lazySingleton<_i982.DatabaseProvider>(
      () => _i955.AppDatabase(gh<_i779.DatabaseFactory>()),
    );
    gh.lazySingleton<_i26.IdGenerator>(() => const _i26.UuidIdGenerator());
    gh.lazySingleton<_i950.TransactionLocalDataSource>(
      () =>
          _i242.SqfliteTransactionLocalDataSource(gh<_i982.DatabaseProvider>()),
    );
    gh.lazySingleton<_i506.CategoryLocalDataSource>(
      () => _i833.SqfliteCategoryLocalDataSource(gh<_i982.DatabaseProvider>()),
    );
    gh.lazySingleton<_i947.BudgetLocalDataSource>(
      () => _i759.SqfliteBudgetLocalDataSource(gh<_i982.DatabaseProvider>()),
    );
    gh.lazySingleton<_i939.CategoryRepository>(
      () => _i929.CategoryRepositoryImpl(
        gh<_i506.CategoryLocalDataSource>(),
        gh<_i26.IdGenerator>(),
      ),
    );
    gh.lazySingleton<_i683.BudgetRepository>(
      () => _i1016.BudgetRepositoryImpl(
        gh<_i947.BudgetLocalDataSource>(),
        gh<_i939.CategoryRepository>(),
        gh<_i26.IdGenerator>(),
      ),
    );
    gh.factory<_i561.DefaultCategoryInitializer>(
      () => _i561.DefaultCategoryInitializer(gh<_i939.CategoryRepository>()),
    );
    gh.lazySingleton<_i530.TransactionRepository>(
      () => _i251.TransactionRepositoryImpl(
        gh<_i950.TransactionLocalDataSource>(),
        gh<_i939.CategoryRepository>(),
        gh<_i26.IdGenerator>(),
      ),
    );
    gh.factory<_i970.TransactionListCubit>(
      () => _i970.TransactionListCubit(
        gh<_i530.TransactionRepository>(),
        gh<_i939.CategoryRepository>(),
      ),
    );
    gh.factory<_i484.TransactionFormCubit>(
      () => _i484.TransactionFormCubit(
        gh<_i530.TransactionRepository>(),
        gh<_i939.CategoryRepository>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i878.DatabaseModule {}
