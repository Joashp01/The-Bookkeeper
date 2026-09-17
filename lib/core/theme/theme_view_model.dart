import 'package:flutter/material.dart';

import 'theme_preference_store.dart';

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

  Future<void> load() async {
    final mode = _decode(await _store.read());
    if (_disposed) return;
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _store.write(_encode(mode));
  }

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
