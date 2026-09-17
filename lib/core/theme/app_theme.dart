import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _seed = Color(0xFF2F6B4F);

  static ThemeData get light => _base(Brightness.light);

  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final baseTextTheme = ThemeData(brightness: brightness).textTheme;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: baseTextTheme.copyWith(
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: _inputBorder(colorScheme, transparent: true),
        enabledBorder: _inputBorder(colorScheme, transparent: true),
        focusedBorder: _inputBorder(colorScheme, focused: true),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        side: BorderSide.none,
        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    ColorScheme scheme, {
    bool transparent = false,
    bool focused = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: focused
          ? BorderSide(color: scheme.primary, width: 2)
          : transparent
          ? BorderSide.none
          : BorderSide(color: scheme.outlineVariant),
    );
  }
}
