import '../models/budget.dart';
import '../models/budget_query.dart';

/// Application-facing operations for monthly budgets.
abstract interface class BudgetRepository {
  /// Returns budgets matching [query], newest period first.
  Future<List<Budget>> getAll({BudgetQuery? query});

  /// Returns the budget with [id] or throws a not-found failure.
  Future<Budget> getById(String id);

  /// Returns the budget for [categoryId] in the `YYYY-MM` [period], if any.
  Future<Budget?> getForCategoryAndPeriod(String categoryId, String period);

  /// Creates a budget for one expense category and calendar month.
  Future<Budget> create({
    required String categoryId,
    required String period,
    required int amountMinor,
  });

  /// Changes the limit of an existing budget; its identity and history stay fixed.
  Future<Budget> update({required String id, required int amountMinor});
}
