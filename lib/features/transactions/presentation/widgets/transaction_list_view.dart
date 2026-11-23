import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../cubit/transaction_list_cubit.dart';
import '../cubit/transaction_list_state.dart';
import 'transaction_filter_bar.dart';
import 'transaction_list_tile.dart';
import 'transaction_state_placeholder.dart';

/// State-aware body of the transaction history screen.
class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionListCubit>();
    final state = context.watch<TransactionListCubit>().state;

    return Column(
      children: [
        const TransactionFilterBar(),
        Expanded(child: _content(context, state, cubit)),
      ],
    );
  }

  Widget _content(
    BuildContext context,
    TransactionListState state,
    TransactionListCubit cubit,
  ) {
    if (state.status != TransactionListStatus.success) {
      return TransactionStatePlaceholder(
        status: state.status,
        message: state.errorMessage,
        onRetry: () => unawaited(cubit.load()),
      );
    }

    final names = <String, String>{
      for (final category in state.categories) category.id: category.name,
    };
    return RefreshIndicator(
      key: const Key('transaction-list'),
      onRefresh: cubit.refresh,
      child: ListView.separated(
        itemCount: state.transactions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = state.transactions[index];
          return TransactionListTile(
            transaction: transaction,
            categoryName: names[transaction.categoryId] ?? 'Unknown category',
            onTap: () => context.go(
              AppRoutes.transactionDetailsPath(transaction.id),
              extra: cubit.refresh,
            ),
          );
        },
      ),
    );
  }
}
