import 'package:finora/core/utils/egp_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EgpAmount.tryParse', () {
    test('converts EGP text to integer piastres', () {
      expect(EgpAmount.tryParse('12'), 1200);
      expect(EgpAmount.tryParse('12.5'), 1250);
      expect(EgpAmount.tryParse('12.34'), 1234);
      expect(EgpAmount.tryParse('0.01'), 1);
    });

    test('trims surrounding whitespace', () {
      expect(EgpAmount.tryParse('  125.50  '), 12550);
    });

    test('rejects invalid or non-positive input', () {
      const invalid = <String>[
        '',
        '   ',
        '0',
        '0.00',
        '-1',
        '.5',
        '12.',
        '12.345',
        '1.2.3',
        '1,000',
        'abc',
      ];

      for (final input in invalid) {
        expect(EgpAmount.tryParse(input), isNull, reason: input);
      }
    });
  });

  group('EgpAmount.parse', () {
    test('returns parsed piastres', () {
      expect(EgpAmount.parse('42.75'), 4275);
    });

    test('throws for invalid input', () {
      expect(() => EgpAmount.parse('invalid'), throwsFormatException);
    });
  });

  group('EgpAmount.format', () {
    test('formats piastres with two decimal places', () {
      expect(EgpAmount.format(1250), 'EGP 12.50');
      expect(EgpAmount.format(1), 'EGP 0.01');
      expect(EgpAmount.format(100000), 'EGP 1000.00');
    });

    test('formats raw values for form fields', () {
      expect(EgpAmount.formatValue(1250), '12.50');
      expect(EgpAmount.formatValue(5), '0.05');
    });

    test('round-trips valid amounts', () {
      for (final amount in <int>[1, 50, 1250, 999999]) {
        expect(EgpAmount.parse(EgpAmount.format(amount).substring(4)), amount);
      }
    });
  });
}
