import 'package:bookshelf/core/theme/theme_preference_store.dart';
import 'package:bookshelf/core/theme/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake store standing in for the sqflite implementation.
class _FakeThemePreferenceStore implements ThemePreferenceStore {
  _FakeThemePreferenceStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}

void main() {
  test('defaults to system before load', () {
    final vm = ThemeViewModel(store: _FakeThemePreferenceStore());

    expect(vm.themeMode, ThemeMode.system);
  });

  test('load restores a persisted choice', () async {
    final vm = ThemeViewModel(store: _FakeThemePreferenceStore('dark'));

    await vm.load();

    expect(vm.themeMode, ThemeMode.dark);
  });

  test('load falls back to system for an unrecognised value', () async {
    final vm = ThemeViewModel(store: _FakeThemePreferenceStore('nonsense'));

    await vm.load();

    expect(vm.themeMode, ThemeMode.system);
  });

  test('setThemeMode updates, notifies, and persists', () async {
    final store = _FakeThemePreferenceStore();
    final vm = ThemeViewModel(store: store);
    var notified = 0;
    vm.addListener(() => notified++);

    await vm.setThemeMode(ThemeMode.light);

    expect(vm.themeMode, ThemeMode.light);
    expect(store.value, 'light');
    expect(notified, 1);
  });

  test('setThemeMode is a no-op when the mode is unchanged', () async {
    final store = _FakeThemePreferenceStore();
    final vm = ThemeViewModel(store: store);
    var notified = 0;
    vm.addListener(() => notified++);

    await vm.setThemeMode(ThemeMode.system); // already system

    expect(notified, 0);
    expect(store.value, isNull, reason: 'no write for a no-op');
  });

  test('cycle advances system → light → dark → system', () async {
    final vm = ThemeViewModel(store: _FakeThemePreferenceStore());

    await vm.cycle();
    expect(vm.themeMode, ThemeMode.light);

    await vm.cycle();
    expect(vm.themeMode, ThemeMode.dark);

    await vm.cycle();
    expect(vm.themeMode, ThemeMode.system);
  });
}
