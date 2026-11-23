import 'package:injectable/injectable.dart';

/// Application-level configuration available throughout the app.
@lazySingleton
class AppConfig {
  /// Display name of the application.
  String get appName => 'Finora';
}
