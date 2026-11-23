import 'package:finora/core/utils/id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final generator = const UuidIdGenerator();

  test('generates RFC-4122 version 4 UUIDs', () {
    final id = generator.newId();
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    expect(pattern.hasMatch(id), isTrue, reason: id);
  });

  test('generates unique identifiers', () {
    final ids = List<String>.generate(100, (_) => generator.newId());
    expect(ids.toSet().length, 100);
  });
}
