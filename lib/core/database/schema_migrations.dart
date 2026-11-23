import 'database_migrator.dart';
import 'tables/categories_table.dart';

/// Ordered schema migrations keyed by their target version.
///
/// v1 is the empty baseline shipped in Milestone 0. Each subsequent version
/// adds one feature table; migrations are additive and replayed on fresh
/// installs.
final Map<int, MigrationStep> schemaMigrations = <int, MigrationStep>{
  1: (_) async {},
  2: createCategoriesTable,
};
