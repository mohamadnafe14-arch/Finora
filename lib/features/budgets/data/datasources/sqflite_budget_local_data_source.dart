import 'package:injectable/injectable.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/tables/budgets_table.dart';
import '../../../../core/utils/date_serializer.dart';
import '../models/budget.dart';
import '../models/budget_query.dart';
import 'budget_local_data_source.dart';

/// SQLite implementation of [BudgetLocalDataSource].
@LazySingleton(as: BudgetLocalDataSource)
class SqfliteBudgetLocalDataSource implements BudgetLocalDataSource {
  const SqfliteBudgetLocalDataSource(this._provider);

  final DatabaseProvider _provider;

  @override
  Future<List<Budget>> getAll({BudgetQuery? query}) async {
    final db = await _provider.database;
    final conditions = <String>[];
    final args = <Object?>[];
    final period = query?.period;
    if (period != null) {
      conditions.add('${BudgetsTable.columnPeriod} = ?');
      args.add(period);
    }
    final categoryId = query?.categoryId;
    if (categoryId != null) {
      conditions.add('${BudgetsTable.columnCategoryId} = ?');
      args.add(categoryId);
    }
    final rows = await db.query(
      BudgetsTable.name,
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy:
          '${BudgetsTable.columnPeriod} DESC, '
          '${BudgetsTable.columnCategoryId} ASC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<Budget?> getById(String id) async {
    final db = await _provider.database;
    final rows = await db.query(
      BudgetsTable.name,
      where: '${BudgetsTable.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Budget?> getForCategoryAndPeriod(
    String categoryId,
    String period,
  ) async {
    final db = await _provider.database;
    final rows = await db.query(
      BudgetsTable.name,
      where:
          '${BudgetsTable.columnCategoryId} = ? '
          'AND ${BudgetsTable.columnPeriod} = ?',
      whereArgs: [categoryId, period],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Budget> insert(Budget budget) async {
    final db = await _provider.database;
    await db.insert(BudgetsTable.name, _toRow(budget));
    return budget;
  }

  @override
  Future<Budget> update(Budget budget) async {
    final db = await _provider.database;
    await db.update(
      BudgetsTable.name,
      _toRow(budget),
      where: '${BudgetsTable.columnId} = ?',
      whereArgs: [budget.id],
    );
    return budget;
  }

  Budget _fromRow(Map<String, Object?> row) => Budget(
    id: row[BudgetsTable.columnId]! as String,
    categoryId: row[BudgetsTable.columnCategoryId]! as String,
    period: row[BudgetsTable.columnPeriod]! as String,
    amountMinor: row[BudgetsTable.columnAmountMinor]! as int,
    createdAt: DateSerializer.parse(
      row[BudgetsTable.columnCreatedAt]! as String,
    ),
    updatedAt: DateSerializer.parse(
      row[BudgetsTable.columnUpdatedAt]! as String,
    ),
  );

  Map<String, Object?> _toRow(Budget budget) => {
    BudgetsTable.columnId: budget.id,
    BudgetsTable.columnCategoryId: budget.categoryId,
    BudgetsTable.columnCategoryType: BudgetsTable.expenseType,
    BudgetsTable.columnPeriod: budget.period,
    BudgetsTable.columnAmountMinor: budget.amountMinor,
    BudgetsTable.columnCreatedAt: DateSerializer.format(budget.createdAt),
    BudgetsTable.columnUpdatedAt: DateSerializer.format(budget.updatedAt),
  };
}
