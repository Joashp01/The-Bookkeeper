import 'package:sqflite/sqflite.dart';

import 'database_opener_native.dart'
    if (dart.library.js_interop) 'database_opener_web.dart';

const String favouritesTable = 'favourites';

const String columnKey = 'key';
const String columnTitle = 'title';
const String columnAuthors = 'authors';
const String columnCoverId = 'cover_id';
const String columnFirstPublishYear = 'first_publish_year';

const String searchCacheTable = 'search_cache';

const String columnQuery = 'query';
const String columnPage = 'page';
const String columnNumFound = 'num_found';
const String columnBooks = 'books';

const String settingsTable = 'settings';

const String columnSettingKey = 'key';
const String columnSettingValue = 'value';

const int databaseVersion = 3;

Future<void> createSchema(Database db, int version) async {
  await _createFavourites(db);
  await _createSearchCache(db);
  await _createSettings(db);
}

Future<void> upgradeSchema(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _createSearchCache(db);
  }
  if (oldVersion < 3) {
    await _createSettings(db);
  }
}

Future<void> _createFavourites(Database db) => db.execute('''
      CREATE TABLE $favouritesTable (
        $columnKey TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnAuthors TEXT NOT NULL,
        $columnCoverId INTEGER,
        $columnFirstPublishYear INTEGER
      )
    ''');

Future<void> _createSearchCache(Database db) => db.execute('''
      CREATE TABLE $searchCacheTable (
        $columnQuery TEXT NOT NULL,
        $columnPage INTEGER NOT NULL,
        $columnNumFound INTEGER NOT NULL,
        $columnBooks TEXT NOT NULL,
        PRIMARY KEY ($columnQuery, $columnPage)
      )
    ''');

Future<void> _createSettings(Database db) => db.execute('''
      CREATE TABLE $settingsTable (
        $columnSettingKey TEXT PRIMARY KEY,
        $columnSettingValue TEXT NOT NULL
      )
    ''');

Future<Database> openAppDatabase() => openDatabaseForPlatform(
  version: databaseVersion,
  onCreate: createSchema,
  onUpgrade: upgradeSchema,
);
