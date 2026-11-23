import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/date_display.dart';
import '../cubit/transaction_form_cubit.dart';
import '../cubit/transaction_form_state.dart';

/// Editable inputs of the transaction form.
class TransactionFormFields extends StatefulWidget {
  const TransactionFormFields({super.key});

  @override
  State<TransactionFormFields> createState() => _TransactionFormFieldsState();
}

class _TransactionFormFieldsState extends State<TransactionFormFields> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionFormCubit>();
    final state = context.watch<TransactionFormCubit>().state;
    _syncControllers(state);
    final categoryId =
        state.categories.any((item) => item.id == state.categoryId)
        ? state.categoryId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<TransactionType>(
          key: const Key('form-type-field'),
          initialValue: state.type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final type in TransactionType.values)
              DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              ),
          ],
          onChanged: (value) {
            if (value != null) unawaited(cubit.typeChanged(value));
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('form-category-field'),
          initialValue: categoryId,
          decoration: InputDecoration(
            labelText: 'Category',
            errorText: state.categoryError,
          ),
          items: [
            for (final category in state.categories)
              DropdownMenuItem(value: category.id, child: Text(category.name)),
          ],
          onChanged: (value) {
            if (value != null) cubit.categorySelected(value);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('form-amount-field'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount (EGP)',
            errorText: state.amountError,
          ),
          onChanged: cubit.amountChanged,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          key: const Key('form-date-field'),
          onPressed: () => _pickDate(context, cubit, state.date),
          icon: const Icon(Icons.calendar_today),
          label: Text(DateDisplay.date(state.date)),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('form-note-field'),
          controller: _note,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
          onChanged: cubit.noteChanged,
        ),
      ],
    );
  }

  void _syncControllers(TransactionFormState state) {
    if (_amount.text != state.amountText) _amount.text = state.amountText;
    final note = state.note ?? '';
    if (_note.text != note) _note.text = note;
  }

  Future<void> _pickDate(
    BuildContext context,
    TransactionFormCubit cubit,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current.toLocal(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) cubit.dateSelected(picked);
  }
}
