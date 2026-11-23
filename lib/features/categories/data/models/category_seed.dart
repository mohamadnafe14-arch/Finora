import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

/// A category definition used for atomic first-run initialization.
class CategorySeed extends Equatable {
  const CategorySeed({required this.name, required this.type});

  /// Display name of the category.
  final String name;

  /// Immutable transaction type of the category.
  final TransactionType type;

  @override
  List<Object?> get props => [name, type];
}
