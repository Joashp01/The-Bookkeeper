import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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

const int databaseVersion = 1;

/// Creates the schema. Passed as `onCreate` to whichever database factory opens
/// the database (sqflite on device, sqflite_common_ffi in tests).
Future<void> createSchema(Database db, int version) async {
  await db.execute('''
    CREATE TABLE $favouritesTable (
      $columnKey TEXT PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnAuthors TEXT NOT NULL,
      $columnCoverId INTEGER,
      $columnFirstPublishYear INTEGER
    )
  ''');
}

/// Opens (creating if needed) the on-device database.
Future<Database> openAppDatabase() async {
  final databasesPath = await getDatabasesPath();
  final path = p.join(databasesPath, 'the_bookkeeper.db');
  return openDatabase(path, version: databaseVersion, onCreate: createSchema);
}
