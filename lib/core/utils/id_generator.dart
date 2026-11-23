import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Abstraction for generating unique identifiers.
abstract interface class IdGenerator {
  /// Returns a new UUID v4 string.
  String newId();
}

/// UUID v4 based [IdGenerator].
@LazySingleton(as: IdGenerator)
class UuidIdGenerator implements IdGenerator {
  /// Creates the generator.
  const UuidIdGenerator();

  static const Uuid _uuid = Uuid();

  @override
  String newId() => _uuid.v4();
}
