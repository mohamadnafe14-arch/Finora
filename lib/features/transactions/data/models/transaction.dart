import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

/// A single income or expense entry, stored in EGP piastres.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amountMinor,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final TransactionType type;
  final int amountMinor;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    type,
    amountMinor,
    note,
    date,
    createdAt,
    updatedAt,
  ];
}
