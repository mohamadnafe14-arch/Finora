import 'package:finora/core/utils/date_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateDisplay', () {
    test('formats a UTC instant using the local calendar day', () {
      final local = DateTime(2026, 1, 15, 23, 30);

      expect(DateDisplay.date(local.toUtc()), '15/01/2026');
    });

    test('pads day, month, hour and minute values', () {
      final local = DateTime(2026, 6, 5, 9, 7);

      expect(DateDisplay.dateTime(local.toUtc()), '05/06/2026 09:07');
    });
  });
}
