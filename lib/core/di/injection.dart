import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Registers all injectable dependencies.
///
/// Must be awaited once at startup before any resolution happens.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
