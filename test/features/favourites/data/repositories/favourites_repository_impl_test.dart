import 'package:bookshelf/features/favourites/data/datasources/favourites_local_data_source.dart';
import 'package:bookshelf/features/favourites/data/dtos/favourite_dto.dart';
import 'package:bookshelf/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake standing in for the SQL data source, so the repository's
/// mapping/delegation is tested without a database.
class _FakeLocalDataSource implements FavouritesLocalDataSource {
  final Map<String, FavouriteDto> _store = {};
  final List<String> deletedKeys = [];

  @override
  Future<List<FavouriteDto>> getAll() async => _store.values.toList();

  @override
  Future<void> upsert(FavouriteDto favourite) async {
    _store[favourite.key] = favourite;
  }

  @override
  Future<void> delete(String key) async {
    deletedKeys.add(key);
    _store.remove(key);
  }
}

const _book = Book(
  key: '/works/OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
  coverId: 111,
  firstPublishYear: 1965,
);

void main() {
  late _FakeLocalDataSource dataSource;
  late FavouritesRepository repository;

  setUp(() {
    dataSource = _FakeLocalDataSource();
    repository = FavouritesRepositoryImpl(localDataSource: dataSource);
  });

  test('addFavourite stores the book and getFavourites maps it back', () async {
    await repository.addFavourite(_book);

    final favourites = await repository.getFavourites();
    expect(favourites, hasLength(1));
    expect(favourites.single, _book);
  });

  test('removeFavourite delegates to the data source', () async {
    await repository.addFavourite(_book);

    await repository.removeFavourite(_book.key);

    expect(dataSource.deletedKeys, ['/works/OL1W']);
    expect(await repository.getFavourites(), isEmpty);
  });
}
