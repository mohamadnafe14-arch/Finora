import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

/// Presentation filters applied before listing transactions.
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.search = '',
    this.type,
    this.categoryId,
    this.from,
    this.to,
  });

  /// Case-insensitive note or category name search.
  final String search;

  /// Optional income/expense filter.
  final TransactionType? type;

  /// Optional category identifier filter.
  final String? categoryId;

  /// Inclusive UTC lower bound.
  final DateTime? from;

  /// Inclusive UTC upper bound.
  final DateTime? to;

  TransactionFilter copyWith({
    String? search,
    Object? type = _unset,
    Object? categoryId = _unset,
    Object? from = _unset,
    Object? to = _unset,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      type: identical(type, _unset) ? this.type : type as TransactionType?,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      from: identical(from, _unset) ? this.from : from as DateTime?,
      to: identical(to, _unset) ? this.to : to as DateTime?,
    );
  }

  static const Object _unset = Object();

  @override
  List<Object?> get props => [search, type, categoryId, from, to];
}
