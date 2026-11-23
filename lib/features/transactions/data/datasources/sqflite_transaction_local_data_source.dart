import 'package:injectable/injectable.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/tables/transactions_table.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/date_serializer.dart';
import '../models/transaction.dart';
import '../models/transaction_query.dart';
import 'transaction_local_data_source.dart';

/// SQLite implementation of [TransactionLocalDataSource].
@LazySingleton(as: TransactionLocalDataSource)
class SqfliteTransactionLocalDataSource implements TransactionLocalDataSource {
  const SqfliteTransactionLocalDataSource(this._provider);

  final DatabaseProvider _provider;

  @override
  Future<List<Transaction>> getAll({TransactionQuery? query}) async {
    final db = await _provider.database;
    final conditions = <String>[];
    final args = <Object?>[];
    final type = query?.type;
    if (type != null) {
      conditions.add('${TransactionsTable.columnType} = ?');
      args.add(type.storageValue);
    }
    final categoryId = query?.categoryId;
    if (categoryId != null) {
      conditions.add('${TransactionsTable.columnCategoryId} = ?');
      args.add(categoryId);
    }
    final from = query?.from;
    if (from != null) {
      conditions.add('${TransactionsTable.columnDate} >= ?');
      args.add(DateSerializer.format(from));
    }
    final to = query?.to;
    if (to != null) {
      conditions.add('${TransactionsTable.columnDate} <= ?');
      args.add(DateSerializer.format(to));
    }
    final rows = await db.query(
      TransactionsTable.name,
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy:
          '${TransactionsTable.columnDate} DESC, '
          '${TransactionsTable.columnId} DESC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<Transaction?> getById(String id) async {
    final db = await _provider.database;
    final rows = await db.query(
      TransactionsTable.name,
      where: '${TransactionsTable.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Transaction> insert(Transaction transaction) async {
    final db = await _provider.database;
    await db.insert(TransactionsTable.name, _toRow(transaction));
    return transaction;
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    final db = await _provider.database;
    await db.update(
      TransactionsTable.name,
      _toRow(transaction),
      where: '${TransactionsTable.columnId} = ?',
      whereArgs: [transaction.id],
    );
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _provider.database;
    await db.delete(
      TransactionsTable.name,
      where: '${TransactionsTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> sumByCategoryAndPeriod(String categoryId, String period) async {
    final db = await _provider.database;
    final rows = await db.rawQuery(
      'SELECT SUM(${TransactionsTable.columnAmountMinor}) AS total '
      'FROM ${TransactionsTable.name} '
      'WHERE ${TransactionsTable.columnCategoryId} = ? '
      'AND substr(${TransactionsTable.columnDate}, 1, 7) = ?',
      [categoryId, period],
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  Transaction _fromRow(Map<String, Object?> row) => Transaction(
    id: row[TransactionsTable.columnId]! as String,
    categoryId: row[TransactionsTable.columnCategoryId]! as String,
    type: transactionTypeFromStorage(
      row[TransactionsTable.columnType]! as String,
    ),
    amountMinor: row[TransactionsTable.columnAmountMinor]! as int,
    note: row[TransactionsTable.columnNote] as String?,
    date: DateSerializer.parse(row[TransactionsTable.columnDate]! as String),
    createdAt: DateSerializer.parse(
      row[TransactionsTable.columnCreatedAt]! as String,
    ),
    updatedAt: DateSerializer.parse(
      row[TransactionsTable.columnUpdatedAt]! as String,
    ),
  );

  Map<String, Object?> _toRow(Transaction transaction) => {
    TransactionsTable.columnId: transaction.id,
    TransactionsTable.columnCategoryId: transaction.categoryId,
    TransactionsTable.columnType: transaction.type.storageValue,
    TransactionsTable.columnAmountMinor: transaction.amountMinor,
    TransactionsTable.columnNote: transaction.note,
    TransactionsTable.columnDate: DateSerializer.format(transaction.date),
    TransactionsTable.columnCreatedAt: DateSerializer.format(
      transaction.createdAt,
    ),
    TransactionsTable.columnUpdatedAt: DateSerializer.format(
      transaction.updatedAt,
    ),
  };
}
