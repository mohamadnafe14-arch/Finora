import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/categories/data/models/category.dart';
import 'package:finora/features/categories/data/repositories/category_repository.dart';

/// In-memory [CategoryRepository] used by repository tests.
class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository(this.type);

  final TransactionType type;
  bool missing = false;

  @override
  Future<List<Category>> getAll({TransactionType? type}) async => <Category>[];

  @override
  Future<Category> getById(String id) async {
    if (missing) throw NotFoundFailure('Missing category');
    return Category(
      id: id,
      name: 'Category',
      type: type,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<Category> create({
    required String name,
    required TransactionType type,
  }) async => throw UnimplementedError();

  @override
  Future<Category> update({required String id, required String name}) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async => throw UnimplementedError();
}
