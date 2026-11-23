import 'package:equatable/equatable.dart';

/// Inclusive UTC bounds derived from a user-selected local calendar day.
class UtcDateRange extends Equatable {
  const UtcDateRange({required this.from, required this.to});

  /// Builds UTC bounds covering the whole local day containing [localDay].
  factory UtcDateRange.forLocalDay(DateTime localDay) {
    final start = DateTime(localDay.year, localDay.month, localDay.day);
    final end = DateTime(
      localDay.year,
      localDay.month,
      localDay.day,
      23,
      59,
      59,
      999,
    );
    return UtcDateRange(from: start.toUtc(), to: end.toUtc());
  }

  /// Inclusive UTC lower bound.
  final DateTime from;

  /// Inclusive UTC upper bound.
  final DateTime to;

  @override
  List<Object?> get props => [from, to];
}
