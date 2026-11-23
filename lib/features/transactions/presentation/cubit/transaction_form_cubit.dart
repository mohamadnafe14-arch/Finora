import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/egp_amount.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../models/transaction_form_mode.dart';
import '../services/transaction_form_loader.dart';
import '../services/transaction_form_saver.dart';
import 'transaction_form_state.dart';

/// ViewModel for creating and editing transactions.
@injectable
class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit(
    TransactionRepository transactions,
    CategoryRepository categories,
  ) : _loader = TransactionFormLoader(transactions, categories),
      _saver = TransactionFormSaver(transactions),
      super(TransactionFormState(date: DateTime.utc(2000)));

  static const _invalidAmount =
      'Enter a positive amount with up to 2 decimals.';

  final TransactionFormLoader _loader;
  final TransactionFormSaver _saver;
  int _generation = 0;

  /// Starts a blank form for [type].
  Future<void> startCreate({
    TransactionType type = TransactionType.expense,
  }) async {
    final generation = ++_generation;
    emit(TransactionFormState.startCreate(type));
    await _loadCategories(type, generation);
  }

  /// Loads an existing transaction for editing.
  Future<void> startEdit(String id) async {
    final generation = ++_generation;
    emit(
      state.copyWith(
        status: TransactionFormStatus.loading,
        mode: TransactionFormMode.edit,
        editingId: id,
        formError: null,
      ),
    );
    await _attempt(
      generation,
      () => _loader.edit(id),
      (data) => emit(
        state.copyWith(
          type: data.transaction.type,
          categoryId: data.transaction.categoryId,
          amountText: EgpAmount.formatValue(data.transaction.amountMinor),
          date: data.transaction.date.toUtc(),
          note: data.transaction.note,
          categories: data.categories,
          status: TransactionFormStatus.ready,
        ),
      ),
      'Unable to load the transaction.',
    );
  }

  /// Changes the transaction type and reloads matching categories.
  Future<void> typeChanged(TransactionType type) async {
    if (type == state.type) return;
    final generation = ++_generation;
    emit(
      state.copyWith(
        status: TransactionFormStatus.loading,
        type: type,
        categories: const [],
        categoryId: null,
        categoryError: null,
        formError: null,
      ),
    );
    await _loadCategories(type, generation);
  }

  /// Selects a category belonging to the current type.
  void categorySelected(String id) =>
      _update(state.copyWith(categoryId: id, categoryError: null));

  /// Updates the raw EGP amount text and its parsed piastre value.
  void amountChanged(String value) => _update(
    state.copyWith(
      amountText: value,
      amountError: value.trim().isEmpty || EgpAmount.tryParse(value) != null
          ? null
          : _invalidAmount,
    ),
  );

  /// Updates the optional note.
  void noteChanged(String value) =>
      _update(state.copyWith(note: value.trim().isEmpty ? null : value));

  /// Updates the transaction date in UTC.
  void dateSelected(DateTime value) =>
      _update(state.copyWith(date: value.toUtc()));

  /// Validates and persists the form through the repository.
  Future<void> submit() async {
    if (state.status == TransactionFormStatus.saving) return;
    final amount = EgpAmount.tryParse(state.amountText);
    final errors = _saver.validate(
      amountText: state.amountText,
      categoryId: state.categoryId,
      categories: state.categories,
      type: state.type,
    );
    if (errors.hasErrors) {
      emit(
        state.copyWith(
          status: TransactionFormStatus.ready,
          amountError: errors.amountError,
          categoryError: errors.categoryError,
          formError: null,
        ),
      );
      return;
    }
    emit(state.copyWith(status: TransactionFormStatus.saving, formError: null));
    await _attempt(
      0,
      () => _saver.save(
        editingId: state.editingId,
        categoryId: state.categoryId!,
        type: state.type,
        amountMinor: amount!,
        note: state.note,
        date: state.date.toUtc(),
      ),
      (transaction) => emit(
        state.copyWith(
          status: TransactionFormStatus.success,
          savedTransactionId: transaction.id,
        ),
      ),
      'Unable to save the transaction.',
    );
  }

  void _update(TransactionFormState next) =>
      emit(next.copyWith(formError: null, status: _editableStatus));

  TransactionFormStatus? get _editableStatus =>
      state.status == TransactionFormStatus.failure
      ? TransactionFormStatus.ready
      : null;

  Future<void> _loadCategories(TransactionType type, int generation) =>
      _attempt(
        generation,
        () => _loader.categories(type),
        (categories) => emit(
          state.copyWith(
            status: TransactionFormStatus.ready,
            categories: categories,
          ),
        ),
        'Unable to load categories.',
      );

  Future<void> _attempt<T>(
    int generation,
    Future<T> Function() action,
    void Function(T value) onSuccess,
    String fallbackMessage,
  ) async {
    try {
      final value = await action();
      if (generation != 0 && generation != _generation) return;
      onSuccess(value);
    } on Failure catch (failure) {
      _fail(failure.message, generation);
    } catch (_) {
      _fail(fallbackMessage, generation);
    }
  }

  void _fail(String message, int generation) {
    if (generation != 0 && generation != _generation) return;
    emit(
      state.copyWith(status: TransactionFormStatus.failure, formError: message),
    );
  }
}
