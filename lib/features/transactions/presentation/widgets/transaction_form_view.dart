import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/transaction_form_cubit.dart';
import '../cubit/transaction_form_state.dart';
import 'transaction_form_actions.dart';
import 'transaction_form_fields.dart';

/// State-aware body of the transaction create/edit screen.
class TransactionFormView extends StatelessWidget {
  const TransactionFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<TransactionFormCubit>().state.status;
    if (status == TransactionFormStatus.initial ||
        status == TransactionFormStatus.loading) {
      return const Center(
        key: Key('transaction-form-loading'),
        child: CircularProgressIndicator(),
      );
    }

    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TransactionFormFields(),
          SizedBox(height: 16),
          TransactionFormActions(),
        ],
      ),
    );
  }
}
