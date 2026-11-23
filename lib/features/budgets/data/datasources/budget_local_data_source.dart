import '../models/budget.dart';
import '../models/budget_query.dart';

/// Local storage contract for budgets.
abstract interface class BudgetLocalDataSource {
  /// Returns budgets matching [query], newest period first.
  Future<List<Budget>> getAll({BudgetQuery? query});

  /// Returns the budget with [id], or `null` when absent.
  Future<Budget?> getById(String id);

  /// Returns the budget for [categoryId] in the `YYYY-MM` [period].
  Future<Budget?> getForCategoryAndPeriod(String categoryId, String period);

  /// Inserts [budget] and returns it.
  Future<Budget> insert(Budget budget);

  /// Persists changes to [budget] and returns it.
  Future<Budget> update(Budget budget);
}
