import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// Landing screen of the application.
class HomePage extends StatelessWidget {
  /// Creates the home screen.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => Text(state.appName),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your finances, offline-first.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.transactions),
              icon: const Icon(Icons.list_alt),
              label: const Text('View transactions'),
            ),
          ],
        ),
      ),
    );
  }
}
