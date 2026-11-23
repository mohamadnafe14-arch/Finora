import 'package:finora/core/enums/transaction_type.dart';
import 'package:finora/core/error/failures.dart';
import 'package:finora/features/categories/data/models/category.dart';
import 'package:finora/features/categories/data/models/category_seed.dart';
import 'package:finora/features/categories/data/repositories/category_repository.dart';

/// In-memory [CategoryRepository] used by repository tests.
class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository(this.type);

  final TransactionType type;
  bool missing = false;
  int initializeCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  List<CategorySeed> initializedSeeds = const [];

  @override
  Future<List<Category>> getAll({TransactionType? type}) async => <Category>[];

  @override
  Future<void> initializeDefaults(Iterable<CategorySeed> seeds) async {
    initializeCalls++;
    initializedSeeds = seeds.toList(growable: false);
  }

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
  Future<Category> update({required String id, required String name}) async {
    updateCalls++;
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    throw UnimplementedError();
  }
}
