import 'package:sqflite/sqflite.dart';

/// Provides the shared SQLite connection to data sources.
abstract interface class DatabaseProvider {
  /// Returns the open database, opening it on first access.
  Future<Database> get database;
}
