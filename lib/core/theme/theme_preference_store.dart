import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';

/// Local persistence for the user's theme choice, behind an interface so the
/// [ThemeViewModel] depends on the abstraction and tests substitute an in-memory
/// (ffi) database — or a fake — at the same seam.
///
/// It stores and returns the raw string value only; the light/dark/system
/// interpretation (a domain decision) lives in the view model, keeping this a
/// pure I/O boundary consistent with the app's other data sources.
abstract interface class ThemePreferenceStore {
  /// The persisted value, or `null` when the user has never chosen one.
  Future<String?> read();

  /// Persists [value], replacing any previous choice.
  Future<void> write(String value);
}

class ThemePreferenceStoreImpl implements ThemePreferenceStore {
  ThemePreferenceStoreImpl({required this.database});

  final Database database;

  /// The single settings row this store owns.
  static const String settingKey = 'theme_mode';

  @override
  Future<String?> read() async {
    final rows = await database.query(
      settingsTable,
      columns: [columnSettingValue],
      where: '$columnSettingKey = ?',
      whereArgs: [settingKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[columnSettingValue] as String;
  }

  @override
  Future<void> write(String value) async {
    await database.insert(
      settingsTable,
      {columnSettingKey: settingKey, columnSettingValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
