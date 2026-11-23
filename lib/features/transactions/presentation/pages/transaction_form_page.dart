import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection.dart';
import '../cubit/transaction_form_cubit.dart';
import '../cubit/transaction_form_state.dart';
import '../widgets/transaction_form_view.dart';

/// Screen for creating or editing a transaction.
class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({
    super.key,
    this.cubit,
    this.transactionId,
    this.onSaved,
  });

  /// Optional preconfigured ViewModel, primarily for isolated widget tests.
  final TransactionFormCubit? cubit;

  /// Identifier of the transaction being edited, or null when creating.
  final String? transactionId;

  /// Optional callback invoked after a successful save.
  final VoidCallback? onSaved;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  late final TransactionFormCubit _cubit;
  late final bool _editing;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? getIt<TransactionFormCubit>();
    _editing = widget.transactionId != null;
    if (_editing) {
      unawaited(_cubit.startEdit(widget.transactionId!));
    } else {
      unawaited(_cubit.startCreate());
    }
  }

  @override
  void dispose() {
    if (widget.cubit == null) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<TransactionFormCubit, TransactionFormState>(
        listener: (context, state) {
          if (state.status == TransactionFormStatus.success) {
            widget.onSaved?.call();
            if (Navigator.of(context).canPop()) context.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_editing ? 'Edit transaction' : 'Add transaction'),
          ),
          body: const TransactionFormView(),
        ),
      ),
    );
  }
}
