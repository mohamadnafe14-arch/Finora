import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

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
      body: const Center(child: Text('Your finances, offline-first.')),
    );
  }
}
