import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../categories/data/models/category.dart';
import '../models/transaction_form_mode.dart';

/// Visual state of the transaction create/edit form.
enum TransactionFormStatus { initial, loading, ready, saving, success, failure }

/// Immutable state of the transaction form ViewModel.
class TransactionFormState extends Equatable {
  const TransactionFormState({
    this.status = TransactionFormStatus.initial,
    this.mode = TransactionFormMode.create,
    this.type = TransactionType.expense,
    this.categories = const [],
    this.categoryId,
    this.amountText = '',
    required this.date,
    this.note,
    this.amountError,
    this.categoryError,
    this.formError,
    this.editingId,
    this.savedTransactionId,
  });

  /// Initial state when starting a blank create form.
  factory TransactionFormState.startCreate(TransactionType type) =>
      TransactionFormState(
        status: TransactionFormStatus.loading,
        mode: TransactionFormMode.create,
        type: type,
        date: DateTime.now().toUtc(),
      );

  static const Object _unset = Object();

  final TransactionFormStatus status;
  final TransactionFormMode mode;
  final TransactionType type;
  final List<Category> categories;
  final String? categoryId;
  final String amountText;
  final DateTime date;
  final String? note;
  final String? amountError;
  final String? categoryError;
  final String? formError;
  final String? editingId;
  final String? savedTransactionId;

  TransactionFormState copyWith({
    TransactionFormStatus? status,
    TransactionFormMode? mode,
    TransactionType? type,
    List<Category>? categories,
    Object? categoryId = _unset,
    String? amountText,
    DateTime? date,
    Object? note = _unset,
    Object? amountError = _unset,
    Object? categoryError = _unset,
    Object? formError = _unset,
    Object? editingId = _unset,
    Object? savedTransactionId = _unset,
  }) {
    return TransactionFormState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      categoryId: _value(categoryId, this.categoryId),
      amountText: amountText ?? this.amountText,
      date: date ?? this.date,

      note: _value(note, this.note),
      amountError: _value(amountError, this.amountError),
      categoryError: _value(categoryError, this.categoryError),
      formError: _value(formError, this.formError),
      editingId: _value(editingId, this.editingId),
      savedTransactionId: _value(savedTransactionId, this.savedTransactionId),
    );
  }

  static T? _value<T>(Object? value, T? current) =>
      identical(value, _unset) ? current : value as T?;

  @override
  List<Object?> get props => [
    status,
    mode,
    type,
    categories,
    categoryId,
    amountText,
    date,
    note,
    amountError,
    categoryError,
    formError,
    editingId,
    savedTransactionId,
  ];
}
