/// Direction of a financial transaction or the category it belongs to.
enum TransactionType { income, expense }

/// Storage helpers for [TransactionType].
extension TransactionTypeStorage on TransactionType {
  /// Canonical lowercase value persisted in SQLite.
  String get storageValue => name;
}

/// Parses a stored transaction type, throwing [FormatException] if unknown.
TransactionType transactionTypeFromStorage(String value) {
  for (final type in TransactionType.values) {
    if (type.name == value.toLowerCase()) {
      return type;
    }
  }
  throw FormatException('Unknown transaction type: $value');
}
