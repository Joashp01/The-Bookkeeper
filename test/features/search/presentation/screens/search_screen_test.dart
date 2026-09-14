import 'dart:async';

import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/favourites/presentation/viewmodels/favourites_view_model.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/search_result.dart';
import 'package:bookshelf/features/search/domain/repositories/search_repository.dart';
import 'package:bookshelf/features/search/presentation/screens/search_screen.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/search_view_model.dart';
import 'package:bookshelf/features/search/presentation/widgets/book_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeRepo implements SearchRepository {
  _FakeRepo(this.responder);

  final Future<Result<SearchResult>> Function(String query, int page) responder;

  @override
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  }) =>
      responder(query, page);
}

class _NoopFavouritesRepository implements FavouritesRepository {
  @override
  Future<List<Book>> getFavourites() async => const [];

  @override
  Future<void> addFavourite(Book book) async {}

  @override
  Future<void> removeFavourite(String key) async {}
}

Book _book(String title) =>
    Book(key: '/works/$title', title: title, authorNames: const ['A'], firstPublishYear: 2000);

Widget _wrap(SearchViewModel viewModel) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SearchViewModel>.value(value: viewModel),
      ChangeNotifierProvider<FavouritesViewModel>(
        create: (_) =>
            FavouritesViewModel(repository: _NoopFavouritesRepository()),
      ),
    ],
    child: const MaterialApp(home: SearchScreen()),
  );
}

Future<void> _search(WidgetTester tester, String term) async {
  await tester.enterText(find.byType(TextField), term);
  await tester.pump(); // fire the (zero) debounce timer
}

void main() {
  testWidgets('initial state prompts the user to search', (tester) async {
    final vm = SearchViewModel(
      repository: _FakeRepo((_, _) async =>
          const Success(SearchResult(books: [], numFound: 0, page: 1))),
    );

    await tester.pumpWidget(_wrap(vm));

    expect(find.text('Search for a book to get started.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('loading state shows a progress indicator', (tester) async {
    final completer = Completer<Result<SearchResult>>();
    final vm = SearchViewModel(
      repository: _FakeRepo((_, _) => completer.future),
      debounceDuration: Duration.zero,
    );

    await tester.pumpWidget(_wrap(vm));
    await _search(tester, 'dune');
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Success(SearchResult(books: [], numFound: 0, page: 1)));
    await tester.pumpAndSettle();
  });

  testWidgets('results state renders a tile per book', (tester) async {
    final vm = SearchViewModel(
      repository: _FakeRepo((_, _) async => Success(
            SearchResult(books: [_book('Dune'), _book('Dune Messiah')], numFound: 2, page: 1),
          )),
      debounceDuration: Duration.zero,
    );

    await tester.pumpWidget(_wrap(vm));
    await _search(tester, 'dune');
    await tester.pumpAndSettle();

    expect(find.byType(BookTile), findsNWidgets(2));
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Dune Messiah'), findsOneWidget);
  });

  testWidgets('empty state shows a no-results message', (tester) async {
    final vm = SearchViewModel(
      repository: _FakeRepo((_, _) async =>
          const Success(SearchResult(books: [], numFound: 0, page: 1))),
      debounceDuration: Duration.zero,
    );

    await tester.pumpWidget(_wrap(vm));
    await _search(tester, 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('No results found.'), findsOneWidget);
    expect(find.byType(BookTile), findsNothing);
  });

  testWidgets('error state shows the message and a retry action', (tester) async {
    final vm = SearchViewModel(
      repository: _FakeRepo((_, _) async =>
          const FailureResult(ServerFailure('Network unavailable'))),
      debounceDuration: Duration.zero,
    );

    await tester.pumpWidget(_wrap(vm));
    await _search(tester, 'dune');
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Network unavailable'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
