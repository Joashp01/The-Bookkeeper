import 'dart:async';

import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/favourites/presentation/viewmodels/favourites_view_model.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/book_detail.dart';
import 'package:bookshelf/features/search/domain/repositories/book_detail_repository.dart';
import 'package:bookshelf/features/search/presentation/screens/detail_screen.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeDetailRepo implements BookDetailRepository {
  _FakeDetailRepo(this.future);

  final Future<Result<BookDetail>> future;

  @override
  Future<Result<BookDetail>> getDetail(Book book) => future;
}

class _NoopFavouritesRepository implements FavouritesRepository {
  @override
  Future<List<Book>> getFavourites() async => const [];

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

const _detail = BookDetail(
  workId: 'OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
  subjects: ['Science Fiction'],
  description: 'A desert epic.',
  firstPublishYear: 1965,
);

Widget _wrap(BookDetailRepository repository) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<FavouritesViewModel>(
        create: (_) =>
            FavouritesViewModel(repository: _NoopFavouritesRepository()),
      ),
      ChangeNotifierProvider<DetailViewModel>(
        create: (_) => DetailViewModel(repository: repository, book: _book),
      ),
    ],
    child: const MaterialApp(home: DetailScreen()),
  );
}

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    final completer = Completer<Result<BookDetail>>();
    await tester.pumpWidget(_wrap(_FakeDetailRepo(completer.future)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Success(_detail));
    await tester.pumpAndSettle();
  });

  testWidgets('renders the loaded book detail', (tester) async {
    await tester.pumpWidget(
      _wrap(_FakeDetailRepo(Future.value(const Success(_detail)))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.text('First published: 1965'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Science Fiction'), findsOneWidget);
    expect(find.text('A desert epic.'), findsOneWidget);
  });

  testWidgets('shows an error with a retry action on failure', (tester) async {
    await tester.pumpWidget(
      _wrap(_FakeDetailRepo(
        Future.value(const FailureResult(ServerFailure('Network unavailable'))),
      )),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load this book.'), findsOneWidget);
    expect(find.text('Network unavailable'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
