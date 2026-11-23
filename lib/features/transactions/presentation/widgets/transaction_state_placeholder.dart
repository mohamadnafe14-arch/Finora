import 'package:material_ui/material_ui.dart';

import '../cubit/transaction_list_state.dart';

/// Loading, empty, and failure content for the history screen.
class TransactionStatePlaceholder extends StatelessWidget {
  const TransactionStatePlaceholder({
    super.key,
    required this.status,
    this.message,
    this.onRetry,
  });

  final TransactionListStatus status;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TransactionListStatus.loading:
        return const Center(
          key: Key('transaction-loading'),
          child: CircularProgressIndicator(),
        );
      case TransactionListStatus.empty:
        return const Center(
          key: Key('transaction-empty'),
          child: Text('No transactions yet'),
        );
      case TransactionListStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message ?? 'Unable to load transactions.'),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('transaction-retry'),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case TransactionListStatus.initial:
      case TransactionListStatus.success:
        return const SizedBox.shrink();
    }
  }
}
