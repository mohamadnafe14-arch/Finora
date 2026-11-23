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
import 'package:finora/core/di/database_module.dart' as _i878;
import 'package:finora/core/utils/id_generator.dart' as _i26;
import 'package:finora/features/home/presentation/cubit/home_cubit.dart'
    as _i808;
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
    gh.lazySingleton<_i955.AppDatabase>(
      () => _i955.AppDatabase(gh<_i779.DatabaseFactory>()),
    );
    gh.lazySingleton<_i26.IdGenerator>(() => const _i26.UuidIdGenerator());
    return this;
  }
}

class _$DatabaseModule extends _i878.DatabaseModule {}
