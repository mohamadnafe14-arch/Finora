/// UTC-to-local date formatting for transaction presentation.
abstract final class DateDisplay {
  /// Formats [value] as `DD/MM/YYYY` in the device local timezone.
  static String date(DateTime value) {
    final local = value.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  /// Formats [value] as `DD/MM/YYYY HH:mm` in the device local timezone.
  static String dateTime(DateTime value) {
    final local = value.toLocal();
    return '${date(value)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
