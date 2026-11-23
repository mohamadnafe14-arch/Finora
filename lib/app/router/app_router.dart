import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/home/presentation/pages/home_page.dart';

/// Central navigation configuration of the application.
@lazySingleton
class AppRouter {
  /// Application router. Feature routes are added here by later milestones.
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
  );
}
