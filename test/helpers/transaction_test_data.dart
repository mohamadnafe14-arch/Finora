import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/features/transactions/data/models/transaction.dart';

/// Creates a deterministic transaction for presentation tests.
Transaction buildTransaction({
  String id = 't1',
  String categoryId = 'c1',
  TransactionType type = TransactionType.expense,
  int amountMinor = 100,
  String? note,
  DateTime? date,
}) {
  return Transaction(
    id: id,
    categoryId: categoryId,
    type: type,
    amountMinor: amountMinor,
    note: note,
    date: date ?? DateTime.utc(2026, 1, 15),
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}
