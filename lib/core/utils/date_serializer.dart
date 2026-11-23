/// Consistent UTC date serialization for persistence.
abstract final class DateSerializer {
  /// Formats [value] as UTC ISO-8601 with fixed millisecond precision.
  static String format(DateTime value) =>
      value.toUtc().copyWith(microsecond: 0).toIso8601String();

  /// Parses a stored UTC ISO-8601 string back into a [DateTime].
  static DateTime parse(String value) => DateTime.parse(value).toUtc();

  /// Returns the `YYYY-MM` budget period containing [value].
  static String periodOf(DateTime value) => format(value).substring(0, 7);
}
