import 'package:finora/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:finora/features/budgets/data/models/budget.dart';
import 'package:finora/features/budgets/data/models/budget_query.dart';

/// In-memory [BudgetLocalDataSource] used by repository tests.
class FakeBudgetDataSource implements BudgetLocalDataSource {
  final List<Budget> items = <Budget>[];
  Object? error;

  @override
  Future<List<Budget>> getAll({BudgetQuery? query}) async {
    _throwIfConfigured();
    return items
        .where((item) {
          if (query?.period != null && item.period != query!.period) {
            return false;
          }
          if (query?.categoryId != null &&
              item.categoryId != query!.categoryId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  @override
  Future<Budget?> getById(String id) async {
    _throwIfConfigured();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Budget?> getForCategoryAndPeriod(
    String categoryId,
    String period,
  ) async {
    _throwIfConfigured();
    for (final item in items) {
      if (item.categoryId == categoryId && item.period == period) return item;
    }
    return null;
  }

  @override
  Future<Budget> insert(Budget budget) async {
    _throwIfConfigured();
    items.add(budget);
    return budget;
  }

  @override
  Future<Budget> update(Budget budget) async {
    _throwIfConfigured();
    final index = items.indexWhere((item) => item.id == budget.id);
    items[index] = budget;
    return budget;
  }

  void _throwIfConfigured() {
    final failure = error;
    if (failure != null) throw failure;
  }
}
