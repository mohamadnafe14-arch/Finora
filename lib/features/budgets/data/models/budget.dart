import 'package:equatable/equatable.dart';

/// A monthly spending limit for one expense category, in EGP piastres.
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.period,
    required this.amountMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;

  /// Calendar month in `YYYY-MM` form.
  final String period;
  final int amountMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    period,
    amountMinor,
    createdAt,
    updatedAt,
  ];
}
