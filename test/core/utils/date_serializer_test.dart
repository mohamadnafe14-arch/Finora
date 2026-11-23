import 'package:finora/core/utils/date_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats with fixed UTC millisecond precision', () {
    final date = DateTime.utc(2026, 11, 23, 15, 42, 59, 123, 456);

    expect(DateSerializer.format(date), '2026-11-23T15:42:59.123Z');
  });

  test('formats local dates as UTC', () {
    final local = DateTime(2026, 1, 1, 2, 0);

    expect(DateSerializer.format(local).endsWith('Z'), isTrue);
    expect(DateSerializer.parse(DateSerializer.format(local)).isUtc, isTrue);
  });

  test('parses stored strings back to the same instant', () {
    final date = DateTime.utc(2026, 6, 30, 12, 0, 5, 7);

    expect(DateSerializer.parse(DateSerializer.format(date)), date);
  });

  test('derives YYYY-MM period from a date', () {
    expect(DateSerializer.periodOf(DateTime.utc(2026, 2, 14)), '2026-02');
  });
}
