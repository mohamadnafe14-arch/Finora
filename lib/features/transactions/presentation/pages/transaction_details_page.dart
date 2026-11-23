import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../cubit/transaction_details_cubit.dart';
import '../cubit/transaction_details_state.dart';
import '../widgets/transaction_details_view.dart';

/// Screen showing a single transaction with edit and delete actions.
class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage({
    super.key,
    required this.transactionId,
    this.cubit,
    this.onChanged,
  });

  final String transactionId;
  final TransactionDetailsCubit? cubit;
  final void Function()? onChanged;

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late final TransactionDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? getIt<TransactionDetailsCubit>();
    unawaited(_cubit.load(widget.transactionId));
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
      child: BlocListener<TransactionDetailsCubit, TransactionDetailsState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == TransactionDetailsStatus.deleted,
        listener: (context, state) {
          widget.onChanged?.call();
          if (Navigator.of(context).canPop()) context.pop();
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Transaction details')),
          floatingActionButton: _EditButton(
            transactionId: widget.transactionId,
          ),
          body: TransactionDetailsView(transactionId: widget.transactionId),
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const Key('edit-transaction-button'),
      onPressed: () => context.go(AppRoutes.editTransaction(transactionId)),
      child: const Icon(Icons.edit),
    );
  }
}
