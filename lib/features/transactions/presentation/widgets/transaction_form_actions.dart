import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/transaction_form_cubit.dart';
import '../cubit/transaction_form_state.dart';

/// Save control and feedback for the transaction form.
class TransactionFormActions extends StatelessWidget {
  const TransactionFormActions({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionFormCubit>().state;
    final saving = state.status == TransactionFormStatus.saving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.formError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              state.formError!,
              key: const Key('form-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (saving)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              key: Key('form-saving'),
              child: CircularProgressIndicator(),
            ),
          ),
        FilledButton.icon(
          key: const Key('form-save-button'),
          onPressed: saving
              ? null
              : () => context.read<TransactionFormCubit>().submit(),
          icon: const Icon(Icons.save),
          label: const Text('Save transaction'),
        ),
      ],
    );
  }
}
