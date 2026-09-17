import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/favourites/presentation/viewmodels/favourites_view_model.dart';
import 'package:bookshelf/features/favourites/presentation/widgets/favourite_button.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeFavouritesRepository implements FavouritesRepository {
  final Map<String, Book> store = {};

  @override
  Future<List<Book>> getFavourites() async => store.values.toList();

  @override
  Future<void> addFavourite(Book book) async => store[book.key] = book;

  @override
  Future<void> removeFavourite(String key) async => store.remove(key);
}

const _book = Book(
  key: '/works/OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
);

void main() {
  testWidgets('toggles the favourite state when tapped', (tester) async {
    final vm = FavouritesViewModel(repository: _FakeFavouritesRepository());

    await tester.pumpWidget(
      ChangeNotifierProvider<FavouritesViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: Scaffold(body: FavouriteButton(book: _book)),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(vm.isFavourite(_book.key), isTrue);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(vm.isFavourite(_book.key), isFalse);
  });
}
