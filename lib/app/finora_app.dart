import 'package:material_ui/material_ui.dart';

import '../core/di/injection.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget of the application.
class FinoraApp extends StatelessWidget {
  /// Creates the root widget.
  const FinoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finora',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: getIt<AppRouter>().router,
    );
  }
}
