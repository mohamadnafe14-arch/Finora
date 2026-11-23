import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_details_state.dart';

/// ViewModel for the read-only transaction details screen.
@injectable
class TransactionDetailsCubit extends Cubit<TransactionDetailsState> {
  TransactionDetailsCubit(this._transactions, this._categories)
    : super(const TransactionDetailsState());

  final TransactionRepository _transactions;
  final CategoryRepository _categories;

  /// Loads the transaction and its category name.
  Future<void> load(String id) async {
    emit(
      const TransactionDetailsState(status: TransactionDetailsStatus.loading),
    );
    try {
      final transaction = await _transactions.getById(id);
      final category = await _categories.getById(transaction.categoryId);
      emit(
        TransactionDetailsState(
          status: TransactionDetailsStatus.success,
          transaction: transaction,
          categoryName: category.name,
        ),
      );
    } on Failure catch (failure) {
      _fail(failure.message);
    } catch (_) {
      _fail('Unable to load the transaction.');
    }
  }

  /// Deletes the loaded transaction.
  Future<void> delete() async {
    final id = state.transaction?.id;
    if (id == null || state.status == TransactionDetailsStatus.deleting) return;
    emit(state.copyWith(status: TransactionDetailsStatus.deleting));
    try {
      await _transactions.delete(id);
      emit(state.copyWith(status: TransactionDetailsStatus.deleted));
    } on Failure catch (failure) {
      _fail(failure.message);
    } catch (_) {
      _fail('Unable to delete the transaction.');
    }
  }

  void _fail(String message) => emit(
    state.copyWith(
      status: TransactionDetailsStatus.failure,
      errorMessage: message,
    ),
  );
}
