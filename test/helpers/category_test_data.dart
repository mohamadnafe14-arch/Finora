import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/categories/data/models/category.dart';

/// Creates a deterministic category for presentation tests.
Category buildCategory({
  String id = 'c1',
  String name = 'Category',
  TransactionType type = TransactionType.expense,
}) {
  return Category(
    id: id,
    name: name,
    type: type,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}
