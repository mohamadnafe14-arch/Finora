import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// Registers database-related dependencies.
@module
abstract class DatabaseModule {
  /// Platform SQLite factory used on Android and iOS.
  @lazySingleton
  sqflite.DatabaseFactory get databaseFactory => sqflite.databaseFactory;
}
