import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

/// A category grouping transactions and budgets.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final TransactionType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, type, createdAt, updatedAt];
}
