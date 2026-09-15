import 'package:bookshelf/core/database/app_database.dart';
import 'package:bookshelf/features/search/data/datasources/search_cache_data_source.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

const _books = [
  Book(
    key: '/works/OL1W',
    title: 'Dune',
    authorNames: ['Frank Herbert'],
    coverId: 111,
    firstPublishYear: 1965,
  ),
  Book(
    key: '/works/OL2W',
    title: 'Dune Messiah',
    authorNames: [],
  ),
];

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;
  late SearchCacheDataSource cache;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options:
          OpenDatabaseOptions(version: databaseVersion, onCreate: createSchema),
    );
    cache = SearchCacheDataSourceImpl(database: database);
  });

  tearDown(() => database.close());

  test('save then read returns the cached page (books round-trip)', () async {
    await cache.save(query: 'dune', page: 1, numFound: 42, books: _books);

    final cached = await cache.read(query: 'dune', page: 1);

    expect(cached, isNotNull);
    expect(cached!.numFound, 42);
    expect(cached.books, hasLength(2));
    expect(cached.books.first.key, '/works/OL1W');
    expect(cached.books.first.authorNames, ['Frank Herbert']);
    expect(cached.books[1].coverId, isNull);
  });

  test('read returns null for a query/page that was never cached', () async {
    expect(await cache.read(query: 'missing', page: 1), isNull);
  });

  test('saving the same query/page replaces the previous entry', () async {
    await cache.save(query: 'dune', page: 1, numFound: 1, books: _books);
    await cache.save(query: 'dune', page: 1, numFound: 99, books: const []);

    final cached = await cache.read(query: 'dune', page: 1);
    expect(cached!.numFound, 99);
    expect(cached.books, isEmpty);
  });
}
