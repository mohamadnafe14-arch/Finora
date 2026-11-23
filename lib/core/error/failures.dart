/// Base type for expected application failures.
sealed class Failure implements Exception {
  /// Creates a failure with a human-readable [message].
  const Failure(this.message);

  /// Description of the failure.
  final String message;

  @override
  String toString() => message;
}

/// Invalid user input or invariant violation.
final class ValidationFailure extends Failure {
  /// Creates a validation failure.
  const ValidationFailure(super.message);
}

/// A requested entity does not exist.
final class NotFoundFailure extends Failure {
  /// Creates a not-found failure.
  const NotFoundFailure(super.message);
}

/// A write conflicts with an existing record or constraint.
final class ConflictFailure extends Failure {
  /// Creates a conflict failure.
  const ConflictFailure(super.message);
}

/// An unexpected local storage error.
final class StorageFailure extends Failure {
  /// Creates a storage failure.
  const StorageFailure(super.message);
}
