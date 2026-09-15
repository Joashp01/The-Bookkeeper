import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:bookshelf/features/favourites/presentation/viewmodels/favourites_view_model.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/presentation/widgets/book_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeFavouritesRepository implements FavouritesRepository {
  _FakeFavouritesRepository(this._initial);

  final List<Book> _initial;

  @override
  Future<List<Book>> getFavourites() async => _initial;

  @override
  Future<void> addFavourite(Book book) async {}

  @override
  Future<void> removeFavourite(String key) async {}
}

const _book = Book(
  key: '/works/OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
);

Widget _wrap(FavouritesViewModel viewModel) {
  return ChangeNotifierProvider<FavouritesViewModel>.value(
    value: viewModel,
    child: const MaterialApp(home: FavouritesScreen()),
  );
}

void main() {
  testWidgets('shows an empty message when there are no favourites',
      (tester) async {
    final vm = FavouritesViewModel(repository: _FakeFavouritesRepository(const []));

    await tester.pumpWidget(_wrap(vm));
    await tester.pumpAndSettle();

    expect(find.text('No favourites yet.'), findsOneWidget);
    expect(find.byType(BookTile), findsNothing);
  });

  testWidgets('lists favourited books after loading', (tester) async {
    final vm = FavouritesViewModel(
      repository: _FakeFavouritesRepository(const [_book]),
    );

    await tester.pumpWidget(_wrap(vm));
    await vm.load();
    await tester.pumpAndSettle();

    expect(find.byType(BookTile), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
  });
}
