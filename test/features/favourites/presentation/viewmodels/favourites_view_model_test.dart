import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/favourites/presentation/viewmodels/favourites_view_model.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake repository. [failOnWrite] lets tests exercise the rollback.
class _FakeFavouritesRepository implements FavouritesRepository {
  _FakeFavouritesRepository({this.failOnWrite = false});

  final bool failOnWrite;
  final Map<String, Book> store = {};

  @override
  Future<List<Book>> getFavourites() async => store.values.toList();

  @override
  Future<void> addFavourite(Book book) async {
    if (failOnWrite) throw Exception('write failed');
    store[book.key] = book;
  }

  @override
  Future<void> removeFavourite(String key) async {
    if (failOnWrite) throw Exception('write failed');
    store.remove(key);
  }
}

const _book = Book(
  key: '/works/OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
);

void main() {
  test('load() populates favourites from the repository', () async {
    final repo = _FakeFavouritesRepository()..store[_book.key] = _book;
    final vm = FavouritesViewModel(repository: repo);

    await vm.load();

    expect(vm.favourites, hasLength(1));
    expect(vm.isFavourite(_book.key), isTrue);
  });

  test('toggle adds a book that was not a favourite', () async {
    final repo = _FakeFavouritesRepository();
    final vm = FavouritesViewModel(repository: repo);

    await vm.toggle(_book);

    expect(vm.isFavourite(_book.key), isTrue);
    expect(repo.store, contains(_book.key));
  });

  test('toggle removes a book that was already a favourite', () async {
    final repo = _FakeFavouritesRepository()..store[_book.key] = _book;
    final vm = FavouritesViewModel(repository: repo);
    await vm.load();

    await vm.toggle(_book);

    expect(vm.isFavourite(_book.key), isFalse);
    expect(repo.store, isNot(contains(_book.key)));
  });

  test('toggle rolls back the optimistic add when persistence fails', () async {
    final repo = _FakeFavouritesRepository(failOnWrite: true);
    final vm = FavouritesViewModel(repository: repo);

    await vm.toggle(_book);

    expect(vm.isFavourite(_book.key), isFalse, reason: 'rolled back on failure');
  });
}
