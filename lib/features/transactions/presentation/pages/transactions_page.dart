import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection.dart';
import '../cubit/transaction_list_cubit.dart';
import '../widgets/transaction_list_view.dart';

/// Transaction history screen.
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, this.cubit});

  /// Optional preconfigured ViewModel, primarily for isolated widget tests.
  final TransactionListCubit? cubit;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final TransactionListCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? getIt<TransactionListCubit>();
    unawaited(_cubit.load());
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
      child: Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: const TransactionListView(),
      ),
    );
  }
}
