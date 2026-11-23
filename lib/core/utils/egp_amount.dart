/// Integer-only EGP amount parsing and formatting.
///
/// Monetary values are represented in piastres: 100 piastres equal 1 EGP.
/// Floating-point arithmetic is deliberately avoided.
abstract final class EgpAmount {
  static final RegExp _pattern = RegExp(r'^\d+(?:\.\d{1,2})?$');

  /// Parses [input] into positive piastres, returning `null` when invalid.
  static int? tryParse(String input) {
    final text = input.trim();
    if (!_pattern.hasMatch(text)) {
      return null;
    }

    final parts = text.split('.');
    final pounds = int.parse(parts.first);
    final fraction = parts.length == 1 ? '' : parts.last.padRight(2, '0');
    final amount = pounds * 100 + (fraction.isEmpty ? 0 : int.parse(fraction));

    return amount > 0 ? amount : null;
  }

  /// Parses [input] into positive piastres or throws [FormatException].
  static int parse(String input) {
    final amount = tryParse(input);
    if (amount == null) {
      throw FormatException('Invalid EGP amount: $input');
    }
    return amount;
  }

  /// Formats [amountMinor] as a decimal value with two places.
  static String formatValue(int amountMinor) {
    final sign = amountMinor < 0 ? '-' : '';
    final absolute = amountMinor.abs();
    final pounds = absolute ~/ 100;
    final piastres = (absolute % 100).toString().padLeft(2, '0');
    return '$sign$pounds.$piastres';
  }

  /// Formats [amountMinor] as an EGP string with two decimal places.
  static String format(int amountMinor) => 'EGP ${formatValue(amountMinor)}';
}
