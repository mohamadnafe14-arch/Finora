import '../../../../core/enums/transaction_type.dart';
import '../models/category.dart';

/// Local storage contract for categories.
abstract interface class CategoryLocalDataSource {
  /// Returns all categories, optionally filtered by [type].
  Future<List<Category>> getAll({TransactionType? type});

  /// Returns the category with [id], or `null` when absent.
  Future<Category?> getById(String id);

  /// Inserts [category] and returns it.
  Future<Category> insert(Category category);

  /// Persists changes to [category] and returns it.
  Future<Category> update(Category category);

  /// Deletes the category with [id].
  Future<void> delete(String id);
}
