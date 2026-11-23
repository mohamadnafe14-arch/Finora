import 'package:finora/core/config/app_config.dart';
import 'package:finora/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  test('resolves AppConfig from the service locator', () {
    expect(getIt<AppConfig>().appName, 'Finora');
  });

  test('AppConfig is registered as a lazy singleton', () {
    expect(getIt<AppConfig>(), same(getIt<AppConfig>()));
  });
}
