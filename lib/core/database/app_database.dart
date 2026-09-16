import 'package:sqflite/sqflite.dart';

// Selects the native (sqflite) opener on mobile/desktop and the WebAssembly
// (sqflite_common_ffi_web) opener on web, so the same schema runs on all targets.
import 'database_opener_native.dart'
    if (dart.library.js_interop) 'database_opener_web.dart';

/// Central definition of the local SQL database: table/column names, the schema
/// creation used by both the real app and tests, and the production opener.
///
/// Keeping the schema in one function means the ffi-backed test database and the
/// on-device database are always created identically.
const String favouritesTable = 'favourites';

const String columnKey = 'key';
const String columnTitle = 'title';
const String columnAuthors = 'authors';
const String columnCoverId = 'cover_id';
const String columnFirstPublishYear = 'first_publish_year';

/// Cache of the most recent search results, keyed by (query, page) so an offline
/// repeat of a previous search can be served from storage (F4).
const String searchCacheTable = 'search_cache';

const String columnQuery = 'query';
const String columnPage = 'page';
const String columnNumFound = 'num_found';
const String columnBooks = 'books';

/// Simple key/value store for user preferences (e.g. the chosen theme mode).
/// One row per setting, keyed by [columnSettingKey].
const String settingsTable = 'settings';

const String columnSettingKey = 'key';
const String columnSettingValue = 'value';

/// Bumped to 3 when the settings table was introduced (2 added the cache).
const int databaseVersion = 3;

/// Creates the full schema on a fresh database.
Future<void> createSchema(Database db, int version) async {
  await _createFavourites(db);
  await _createSearchCache(db);
  await _createSettings(db);
}

/// Applies incremental migrations for existing installs.
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

/// Opens (creating/upgrading if needed) the database for the current platform.
Future<Database> openAppDatabase() => openDatabaseForPlatform(
      version: databaseVersion,
      onCreate: createSchema,
      onUpgrade: upgradeSchema,
    );
