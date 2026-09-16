import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Opens the database on web using sqlite compiled to WebAssembly. Persistence
/// is provided by a shared worker (see `web/sqflite_sw.js` and
/// `web/sqlite3.wasm`, vendored via `dart run sqflite_common_ffi_web:setup`).
Future<Database> openDatabaseForPlatform({
  required int version,
  required OnDatabaseCreateFn onCreate,
  required OnDatabaseVersionChangeFn onUpgrade,
}) {
  return databaseFactoryFfiWeb.openDatabase(
    'the_bookkeeper.db',
    options: OpenDatabaseOptions(
      version: version,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    ),
  );
}
