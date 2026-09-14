import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openAppDatabase();
  runApp(BookshelfApp(database: database));
}
