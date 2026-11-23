import 'package:finora/core/utils/utc_date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UtcDateRange.forLocalDay', () {
    test('builds inclusive UTC boundaries from local start and end', () {
      final selected = DateTime(2026, 1, 15, 23, 45);
      final localStart = DateTime(2026, 1, 15);
      final localEnd = DateTime(2026, 1, 15, 23, 59, 59, 999);

      final range = UtcDateRange.forLocalDay(selected);

      expect(range.from, localStart.toUtc());
      expect(range.to, localEnd.toUtc());
      expect(range.from.isUtc, isTrue);
      expect(range.to.isUtc, isTrue);
      expect(range.from.toLocal(), localStart);
      expect(range.to.toLocal(), localEnd);
    });

    test('preserves the selected local calendar day after conversion', () {
      final selected = DateTime(2026, 6, 30, 17, 20);
      final selectedUtc = selected.toUtc();
      final range = UtcDateRange.forLocalDay(selected);

      expect(
        range.from.isBefore(selectedUtc) || range.from == selectedUtc,
        isTrue,
      );
      expect(range.to.isAfter(selectedUtc) || range.to == selectedUtc, isTrue);
      expect(range.from.toLocal().year, selected.year);
      expect(range.from.toLocal().month, selected.month);
      expect(range.from.toLocal().day, selected.day);
      expect(range.to.toLocal().year, selected.year);
      expect(range.to.toLocal().month, selected.month);
      expect(range.to.toLocal().day, selected.day);
    });

    test('excludes adjacent local days', () {
      final range = UtcDateRange.forLocalDay(DateTime(2026, 3, 8, 12));
      final previousDayEnd = DateTime(2026, 3, 7, 23, 59, 59, 999).toUtc();
      final nextDayStart = DateTime(2026, 3, 9).toUtc();

      expect(previousDayEnd.isBefore(range.from), isTrue);
      expect(nextDayStart.isAfter(range.to), isTrue);
    });

    test('uses value equality', () {
      final first = UtcDateRange.forLocalDay(DateTime(2026, 5, 1, 9));
      final second = UtcDateRange.forLocalDay(DateTime(2026, 5, 1, 21));

      expect(first, second);
    });
  });
}
