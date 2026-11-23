import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/date_display.dart';
import '../../../../core/utils/utc_date_range.dart';
import '../cubit/transaction_list_cubit.dart';

/// Search, type, category, and local-day controls for the history screen.
class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionListCubit>();
    final state = context.watch<TransactionListCubit>().state;
    final from = state.filter.from;
    final dateLabel = from == null ? 'Any date' : DateDisplay.date(from);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            key: const Key('transaction-search-field'),
            decoration: const InputDecoration(
              labelText: 'Search transactions',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: cubit.searchChanged,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              DropdownButton<TransactionType?>(
                value: state.filter.type,
                hint: const Text('Type'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All types')),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                ],
                onChanged: (value) => unawaited(cubit.typeFilterChanged(value)),
              ),
              DropdownButton<String?>(
                value: state.filter.categoryId,
                hint: const Text('Category'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...state.categories.map(
                    (category) => DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    unawaited(cubit.categoryFilterChanged(value)),
              ),
              TextButton.icon(
                key: const Key('transaction-date-filter'),
                onPressed: () => _selectDay(context, cubit, from),
                icon: const Icon(Icons.date_range),
                label: Text(dateLabel),
              ),
              TextButton(
                key: const Key('transaction-clear-filters'),
                onPressed: () => unawaited(cubit.clearFilters()),
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDay(
    BuildContext context,
    TransactionListCubit cubit,
    DateTime? from,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      await cubit.dateRangeChanged(UtcDateRange.forLocalDay(picked));
    }
  }
}
