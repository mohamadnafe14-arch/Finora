import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/date_display.dart';
import '../../../../core/utils/egp_amount.dart';
import '../cubit/transaction_details_cubit.dart';
import '../cubit/transaction_details_state.dart';

/// State-aware body of the transaction details screen.
class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionDetailsCubit>().state;
    switch (state.status) {
      case TransactionDetailsStatus.initial:
      case TransactionDetailsStatus.loading:
        return const Center(
          key: Key('details-loading'),
          child: CircularProgressIndicator(),
        );
      case TransactionDetailsStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage ?? 'Unable to load details.'),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('details-retry'),
                onPressed: () => unawaited(
                  context.read<TransactionDetailsCubit>().load(transactionId),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case TransactionDetailsStatus.success:
      case TransactionDetailsStatus.deleting:
      case TransactionDetailsStatus.deleted:
        return _DetailsContent(state: state);
    }
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.state});

  final TransactionDetailsState state;

  @override
  Widget build(BuildContext context) {
    final transaction = state.transaction;
    if (transaction == null) return const SizedBox.shrink();
    final deleting = state.status == TransactionDetailsStatus.deleting;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          key: const Key('details-category'),
          leading: const Icon(Icons.category),
          title: const Text('Category'),
          subtitle: Text(state.categoryName ?? 'Unknown category'),
        ),
        ListTile(
          key: const Key('details-amount'),
          leading: const Icon(Icons.attach_money),
          title: const Text('Amount'),
          subtitle: Text(EgpAmount.format(transaction.amountMinor)),
        ),
        ListTile(
          key: const Key('details-date'),
          leading: const Icon(Icons.calendar_today),
          title: const Text('Date'),
          subtitle: Text(DateDisplay.dateTime(transaction.date)),
        ),
        ListTile(
          key: const Key('details-note'),
          leading: const Icon(Icons.notes),
          title: const Text('Note'),
          subtitle: Text(transaction.note ?? '—'),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const Key('details-delete'),
          onPressed: deleting ? null : () => _confirmDelete(context),
          icon: const Icon(Icons.delete),
          label: const Text('Delete transaction'),
        ),
        if (deleting)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              key: Key('details-deleting'),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TransactionDetailsCubit>().delete();
    }
  }
}
