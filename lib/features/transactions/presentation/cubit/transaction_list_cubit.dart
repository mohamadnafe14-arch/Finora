import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/utc_date_range.dart';
import '../../../categories/data/models/category.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../data/models/transaction.dart';
import '../../data/models/transaction_query.dart';
import '../../data/repositories/transaction_repository.dart';
import '../models/transaction_filter.dart';
import 'transaction_list_state.dart';

/// ViewModel for the transaction history screen.
@injectable
class TransactionListCubit extends Cubit<TransactionListState> {
  TransactionListCubit(this._transactions, this._categories)
    : super(const TransactionListState());

  final TransactionRepository _transactions;
  final CategoryRepository _categories;
  List<Transaction> _source = const [];

  /// Loads categories and transactions using the current structural filters.
  Future<void> load() async {
    emit(
      state.copyWith(status: TransactionListStatus.loading, errorMessage: null),
    );
    try {
      final categories = await _categories.getAll();
      final results = await _transactions.getAll(query: _query());
      _source = List.unmodifiable(results);
      final visible = _search(categories);
      emit(
        state.copyWith(
          status: _statusFor(visible),
          categories: categories,
          transactions: visible,
          errorMessage: null,
        ),
      );
    } on Failure catch (failure) {
      _fail(failure.message);
    } catch (_) {
      _fail('Unable to load transactions.');
    }
  }

  /// Reloads after a create, edit, or delete result.
  Future<void> refresh() => load();

  /// Applies a text search over notes and category names without re-querying.
  void searchChanged(String value) {
    final visible = _search(state.categories, search: value);
    emit(
      state.copyWith(
        filter: state.filter.copyWith(search: value),
        transactions: visible,
        status: _statusFor(visible),
      ),
    );
  }

  /// Changes the income/expense filter and clears an incompatible category.
  Future<void> typeFilterChanged(TransactionType? type) async {
    final selected = state.filter.categoryId;
    final matches = state.categories.where(
      (category) => category.id == selected && category.type == type,
    );
    final categoryId = selected == null || matches.isNotEmpty ? selected : null;
    emit(
      state.copyWith(
        filter: state.filter.copyWith(type: type, categoryId: categoryId),
      ),
    );
    await load();
  }

  /// Changes the category filter.
  Future<void> categoryFilterChanged(String? categoryId) async {
    emit(state.copyWith(filter: state.filter.copyWith(categoryId: categoryId)));
    await load();
  }

  /// Changes the inclusive UTC date range derived from a local calendar day.
  Future<void> dateRangeChanged(UtcDateRange? range) async {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(from: range?.from, to: range?.to),
      ),
    );
    await load();
  }

  /// Clears all filters and reloads the full history.
  Future<void> clearFilters() async {
    emit(state.copyWith(filter: const TransactionFilter()));
    await load();
  }

  TransactionQuery _query() => TransactionQuery(
    type: state.filter.type,
    categoryId: state.filter.categoryId,
    from: state.filter.from,
    to: state.filter.to,
  );

  List<Transaction> _search(List<Category> categories, {String? search}) {
    final term = (search ?? state.filter.search).trim().toLowerCase();
    if (term.isEmpty) return _source;
    final names = <String, String>{
      for (final category in categories)
        category.id: category.name.toLowerCase(),
    };
    return _source
        .where((transaction) {
          final note = transaction.note?.toLowerCase() ?? '';
          final categoryName = names[transaction.categoryId] ?? '';
          return note.contains(term) || categoryName.contains(term);
        })
        .toList(growable: false);
  }

  TransactionListStatus _statusFor(List<Transaction> transactions) =>
      transactions.isEmpty
      ? TransactionListStatus.empty
      : TransactionListStatus.success;

  void _fail(String message) {
    _source = const [];
    emit(
      state.copyWith(
        status: TransactionListStatus.failure,
        transactions: const [],
        errorMessage: message,
      ),
    );
  }
}
