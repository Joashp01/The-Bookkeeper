import 'package:flutter/material.dart';

/// Central theme definitions. Light and dark are both provided from the start
/// so the app can honour the platform brightness; the visual goal is only
/// "clean and legible" per the brief.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF3B6E4F);

  static ThemeData get light => _base(Brightness.light);

  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
