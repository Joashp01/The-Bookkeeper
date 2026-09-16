import 'dart:io';

import 'package:bookshelf/core/database/app_database.dart';
import 'package:bookshelf/core/theme/theme_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

Future<Database> _openInMemory() => databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options:
          OpenDatabaseOptions(version: databaseVersion, onCreate: createSchema),
    );

void main() {
  setUpAll(sqfliteFfiInit);

  group('ThemePreferenceStore (in-memory)', () {
    late Database database;
    late ThemePreferenceStore store;

    setUp(() async {
      database = await _openInMemory();
      store = ThemePreferenceStoreImpl(database: database);
    });

    tearDown(() => database.close());

    test('read returns null before anything is written', () async {
      expect(await store.read(), isNull);
    });

    test('write then read returns the stored value', () async {
      await store.write('dark');

      expect(await store.read(), 'dark');
    });

    test('write replaces the previous value rather than adding a row', () async {
      await store.write('dark');
      await store.write('light');

      expect(await store.read(), 'light');
    });
  });

  test('theme choice survives a database restart (persistence)', () async {
    final dir = Directory.systemTemp.createTempSync('theme_test');
    final path = p.join(dir.path, 'restart.db');
    final options =
        OpenDatabaseOptions(version: databaseVersion, onCreate: createSchema);

    // Open, write, and close to simulate the app shutting down.
    var database = await databaseFactoryFfi.openDatabase(path, options: options);
    await ThemePreferenceStoreImpl(database: database).write('dark');
    await database.close();

    // Re-open the same file: the choice must still be there.
    database = await databaseFactoryFfi.openDatabase(path, options: options);
    final value = await ThemePreferenceStoreImpl(database: database).read();
    await database.close();
    dir.deleteSync(recursive: true);

    expect(value, 'dark');
  });
}
