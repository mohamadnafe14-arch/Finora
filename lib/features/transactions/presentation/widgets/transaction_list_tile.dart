import 'package:material_ui/material_ui.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/date_display.dart';
import '../../../../core/utils/egp_amount.dart';
import '../../data/models/transaction.dart';

/// Compact row shown in the transaction history list.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.categoryName,
    this.onTap,
  });

  final Transaction transaction;
  final String categoryName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateDisplay.date(transaction.date);
    final note = transaction.note;
    final subtitle = note == null || note.isEmpty ? date : '$note · $date';
    final income = transaction.type == TransactionType.income;

    return ListTile(
      key: ValueKey('transaction-${transaction.id}'),
      onTap: onTap,
      leading: CircleAvatar(
        child: Icon(income ? Icons.south_west : Icons.north_east),
      ),
      title: Text(categoryName),
      subtitle: Text(subtitle),
      trailing: Text(
        EgpAmount.format(transaction.amountMinor),
        style: TextStyle(
          color: income
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
