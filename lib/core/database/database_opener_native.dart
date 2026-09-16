import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the database on native platforms (Android/iOS/desktop) using the
/// default sqflite factory and the platform's databases directory.
Future<Database> openDatabaseForPlatform({
  required int version,
  required OnDatabaseCreateFn onCreate,
  required OnDatabaseVersionChangeFn onUpgrade,
}) async {
  final databasesPath = await getDatabasesPath();
  final path = p.join(databasesPath, 'the_bookkeeper.db');
  return openDatabase(
    path,
    version: version,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
  );
}
