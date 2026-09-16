import 'package:flutter/material.dart';

import 'theme_preference_store.dart';

/// Owns the app-wide theme choice (bonus: light/dark switch).
///
/// It maps between Flutter's [ThemeMode] and the raw string the
/// [ThemePreferenceStore] persists — that interpretation is the one bit of
/// logic that belongs above the data layer. Provided once, app-wide, so the
/// [MaterialApp] and the toggle in the app bar read a single source of truth.
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({required ThemePreferenceStore store})
      : _store = store; // ignore: prefer_initializing_formals

  final ThemePreferenceStore _store;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Loads the persisted choice, defaulting to [ThemeMode.system] when the user
  /// has never picked one (or the stored value is unrecognised).
  ///
  /// The read is deferred at startup, so this may resolve after the widget tree
  /// (and this notifier) is gone; the guard avoids notifying after disposal.
  Future<void> load() async {
    final mode = _decode(await _store.read());
    if (_disposed) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Selects [mode], updating the UI immediately and persisting the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _store.write(_encode(mode));
  }

  /// Advances system → light → dark → system, for a single-tap toggle.
  Future<void> cycle() => setThemeMode(_next(_themeMode));

  static ThemeMode _next(ThemeMode mode) => switch (mode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
      };

  static ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
