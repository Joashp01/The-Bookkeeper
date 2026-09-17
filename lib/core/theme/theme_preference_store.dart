import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';

abstract interface class ThemePreferenceStore {
  Future<String?> read();

  Future<void> write(String value);
}

class ThemePreferenceStoreImpl implements ThemePreferenceStore {
  ThemePreferenceStoreImpl({required this.database});

  final Database database;

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
    await database.insert(settingsTable, {
      columnSettingKey: settingKey,
      columnSettingValue: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
