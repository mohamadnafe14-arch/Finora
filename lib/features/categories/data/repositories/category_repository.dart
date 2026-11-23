import '../../../../core/enums/transaction_type.dart';
import '../models/category.dart';
import '../models/category_seed.dart';

/// Application-facing operations for categories.
abstract interface class CategoryRepository {
  /// Returns all categories, optionally filtered by [type].
  Future<List<Category>> getAll({TransactionType? type});

  /// Atomically seeds [seeds] when the category table is empty.
  ///
  /// Existing categories are never updated, deleted, or overwritten.
  Future<void> initializeDefaults(Iterable<CategorySeed> seeds);

  /// Returns the category with [id] or throws a not-found failure.
  Future<Category> getById(String id);

  /// Creates a validated category with a fresh identifier.
  Future<Category> create({
    required String name,
    required TransactionType type,
  });

  /// Renames an existing category; its type is immutable.
  Future<Category> update({required String id, required String name});

  /// Deletes a category when no financial records reference it.
  Future<void> delete(String id);
}
