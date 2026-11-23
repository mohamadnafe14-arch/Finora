import '../../../../core/enums/transaction_type.dart';
import '../models/category.dart';

/// Application-facing operations for categories.
abstract interface class CategoryRepository {
  /// Returns all categories, optionally filtered by [type].
  Future<List<Category>> getAll({TransactionType? type});

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
