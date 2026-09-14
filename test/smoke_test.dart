import 'package:bookshelf/app.dart';
import 'package:bookshelf/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;

  // Open outside the widget-test body: the test binding's fake clock does not
  // drain native async, so opening the database inside testWidgets would hang.
  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options:
          OpenDatabaseOptions(version: databaseVersion, onCreate: createSchema),
    );
  });

  tearDown(() => database.close());

  testWidgets('app boots to the search screen', (tester) async {
    await tester.pumpWidget(BookshelfApp(database: database));

    expect(find.text('The Bookkeeper'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
