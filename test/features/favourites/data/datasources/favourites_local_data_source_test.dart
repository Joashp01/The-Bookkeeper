import 'dart:io';

import 'package:bookshelf/core/database/app_database.dart';
import 'package:bookshelf/features/favourites/data/datasources/favourites_local_data_source.dart';
import 'package:bookshelf/features/favourites/data/dtos/favourite_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

const _dune = FavouriteDto(
  key: '/works/OL1W',
  title: 'Dune',
  authors: ['Frank Herbert'],
  coverId: 111,
  firstPublishYear: 1965,
);

Future<Database> _openInMemory() => databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: databaseVersion, onCreate: createSchema),
    );

void main() {
  setUpAll(sqfliteFfiInit);

  group('FavouritesLocalDataSource (in-memory)', () {
    late Database database;
    late FavouritesLocalDataSource dataSource;

    setUp(() async {
      database = await _openInMemory();
      dataSource = FavouritesLocalDataSourceImpl(database: database);
    });

    tearDown(() => database.close());

    test('upsert then getAll returns the favourite', () async {
      await dataSource.upsert(_dune);

      final all = await dataSource.getAll();
      expect(all, hasLength(1));
      expect(all.single.key, '/works/OL1W');
      expect(all.single.authors, ['Frank Herbert']);
    });

    test('upsert on the same key replaces rather than duplicates', () async {
      await dataSource.upsert(_dune);
      await dataSource.upsert(_dune);

      expect(await dataSource.getAll(), hasLength(1));
    });

    test('delete removes the favourite', () async {
      await dataSource.upsert(_dune);
      await dataSource.delete(_dune.key);

      expect(await dataSource.getAll(), isEmpty);
    });
  });

  test('favourites survive a database restart (persistence)', () async {
    final dir = Directory.systemTemp.createTempSync('fav_test');
    final path = p.join(dir.path, 'restart.db');
    final options =
        OpenDatabaseOptions(version: databaseVersion, onCreate: createSchema);

    // Open, write, and close to simulate the app shutting down.
    var database = await databaseFactoryFfi.openDatabase(path, options: options);
    await FavouritesLocalDataSourceImpl(database: database).upsert(_dune);
    await database.close();

    // Re-open the same file: the favourite must still be there.
    database = await databaseFactoryFfi.openDatabase(path, options: options);
    final all = await FavouritesLocalDataSourceImpl(database: database).getAll();
    await database.close();
    dir.deleteSync(recursive: true);

    expect(all, hasLength(1));
    expect(all.single.key, '/works/OL1W');
  });
}
