import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/presentation/widgets/book_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _book = Book(
  key: '/works/OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
  firstPublishYear: 1965,
);

Widget _wrap(Book book, {double textScale = 1.0}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: BookTile(book: book)),
      ),
    ),
  );
}

void main() {
  testWidgets('exposes a natural-language label for screen readers', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_book));

    final labels = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((s) => s.properties.label);
    expect(labels, contains('Frank Herbert, published 1965'));
  });

  testWidgets('lays out without overflow at large text scale', (tester) async {
    await tester.pumpWidget(_wrap(_book, textScale: 3.0));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
