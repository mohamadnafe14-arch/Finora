import 'package:sqflite/sqflite.dart';

import 'failures.dart';

/// Translates SQLite errors into typed application failures.
abstract final class DatabaseErrorMapper {
  /// Maps a database [error] to the closest application failure.
  static Failure map(Object error) {
    if (error is DatabaseException) {
      final message = error.toString();
      if (error.isUniqueConstraintError()) {
        return const ConflictFailure('A record with the same value exists.');
      }
      if (message.contains('FOREIGN KEY constraint failed')) {
        return const ConflictFailure('The record is referenced by other data.');
      }
      if (message.contains('CHECK constraint failed')) {
        return const ValidationFailure('A value violates a database rule.');
      }
    }
    return StorageFailure('Database operation failed: $error');
  }
}
