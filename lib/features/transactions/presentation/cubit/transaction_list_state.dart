import 'package:equatable/equatable.dart';

import '../../../categories/data/models/category.dart';
import '../../data/models/transaction.dart';
import '../models/transaction_filter.dart';

/// Visual state of the transaction history screen.
enum TransactionListStatus { initial, loading, success, empty, failure }

/// Immutable state of the transaction history ViewModel.
class TransactionListState extends Equatable {
  const TransactionListState({
    this.status = TransactionListStatus.initial,
    this.transactions = const [],
    this.categories = const [],
    this.filter = const TransactionFilter(),
    this.errorMessage,
  });

  static const Object _unset = Object();

  final TransactionListStatus status;
  final List<Transaction> transactions;
  final List<Category> categories;
  final TransactionFilter filter;
  final String? errorMessage;

  bool get isLoading => status == TransactionListStatus.loading;

  TransactionListState copyWith({
    TransactionListStatus? status,
    List<Transaction>? transactions,
    List<Category>? categories,
    TransactionFilter? filter,
    Object? errorMessage = _unset,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    categories,
    filter,
    errorMessage,
  ];
}
