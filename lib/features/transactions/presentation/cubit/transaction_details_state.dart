import 'package:equatable/equatable.dart';

import '../../data/models/transaction.dart';

/// Status of the transaction details screen.
enum TransactionDetailsStatus {
  initial,
  loading,
  success,
  deleting,
  deleted,
  failure,
}

/// Immutable state of the transaction details ViewModel.
class TransactionDetailsState extends Equatable {
  const TransactionDetailsState({
    this.status = TransactionDetailsStatus.initial,
    this.transaction,
    this.categoryName,
    this.errorMessage,
  });

  final TransactionDetailsStatus status;
  final Transaction? transaction;
  final String? categoryName;
  final String? errorMessage;

  TransactionDetailsState copyWith({
    TransactionDetailsStatus? status,
    Transaction? transaction,
    String? categoryName,
    String? errorMessage,
  }) {
    return TransactionDetailsState(
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      categoryName: categoryName ?? this.categoryName,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transaction, categoryName, errorMessage];
}
