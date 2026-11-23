import 'package:injectable/injectable.dart';

import '../data/repositories/category_repository.dart';
import 'default_categories.dart';

/// Idempotently seeds default categories for first-time users.
@injectable
class DefaultCategoryInitializer {
  const DefaultCategoryInitializer(this._categories);

  final CategoryRepository _categories;

  /// Inserts all defaults once through the atomic repository operation.
  Future<void> initialize() =>
      _categories.initializeDefaults(DefaultCategories.seeds);
}
