import 'package:finora/app/router/app_router.dart';
import 'package:finora/app/router/app_routes.dart';
import 'package:finora/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  test('registers home and transaction history routes', () {
    final routes = getIt<AppRouter>().router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    expect(routes, containsAll([AppRoutes.home, AppRoutes.transactions]));
  });
}
