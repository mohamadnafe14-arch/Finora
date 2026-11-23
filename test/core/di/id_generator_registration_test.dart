import 'package:finora/core/di/injection.dart';
import 'package:finora/core/utils/id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  test('IdGenerator resolves from the service locator', () {
    final generator = getIt<IdGenerator>();

    expect(generator, isA<UuidIdGenerator>());
    expect(generator.newId(), isNotEmpty);
  });
}
