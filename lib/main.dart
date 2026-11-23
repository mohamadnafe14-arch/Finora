import 'package:material_ui/material_ui.dart';

import 'app/finora_app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const FinoraApp());
}
