import 'package:material_ui/material_ui.dart';

import 'app/finora_app.dart';
import 'core/di/injection.dart';
import 'features/categories/initialization/default_category_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<DefaultCategoryInitializer>().initialize();
  runApp(const FinoraApp());
}
