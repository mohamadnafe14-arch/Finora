import 'package:equatable/equatable.dart';

/// Optional filters for listing budgets.
class BudgetQuery extends Equatable {
  const BudgetQuery({this.period, this.categoryId});

  /// Exact `YYYY-MM` month.
  final String? period;
  final String? categoryId;

  @override
  List<Object?> get props => [period, categoryId];
}
