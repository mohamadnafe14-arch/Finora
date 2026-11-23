import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

/// Optional filters for listing transactions.
class TransactionQuery extends Equatable {
  const TransactionQuery({this.type, this.categoryId, this.from, this.to});

  final TransactionType? type;
  final String? categoryId;

  /// Inclusive UTC lower bound of the transaction date.
  final DateTime? from;

  /// Inclusive UTC upper bound of the transaction date.
  final DateTime? to;

  @override
  List<Object?> get props => [type, categoryId, from, to];
}
