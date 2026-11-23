import 'package:material_ui/material_ui.dart';

/// Finora's Material 3 themes.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF00695C);

  /// Light theme.
  static ThemeData get light =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed));

  /// Dark theme.
  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
