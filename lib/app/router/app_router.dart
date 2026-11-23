import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import 'app_routes.dart';

/// Central navigation configuration of the application.
@lazySingleton
class AppRouter {
  /// Application router. Feature routes are added here by later milestones.
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsPage(),
      ),
    ],
  );
}
