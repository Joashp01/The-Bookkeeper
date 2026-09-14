import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Book buildBook({
    List<String> authorNames = const ['Frank Herbert'],
    int? coverId = 12345,
    int? firstPublishYear = 1965,
  }) {
    return Book(
      key: '/works/OL1W',
      title: 'Dune',
      authorNames: authorNames,
      coverId: coverId,
      firstPublishYear: firstPublishYear,
    );
  }

  group('Book display decisions (F5)', () {
    test('authorDisplay joins multiple authors', () {
      final book = buildBook(authorNames: const ['A', 'B']);
      expect(book.authorDisplay, 'A, B');
    });

    test('authorDisplay falls back when there are no authors', () {
      final book = buildBook(authorNames: const []);
      expect(book.authorDisplay, 'Unknown author');
    });

    test('yearDisplay shows the year when present', () {
      expect(buildBook().yearDisplay, '1965');
    });

    test('yearDisplay falls back when the year is absent', () {
      expect(buildBook(firstPublishYear: null).yearDisplay, 'Year unknown');
    });

    test('coverUrl is built from the cover id', () {
      expect(
        buildBook(coverId: 42).coverUrl,
        'https://covers.openlibrary.org/b/id/42-M.jpg',
      );
    });

    test('coverUrl is null when the cover is absent', () {
      expect(buildBook(coverId: null).coverUrl, isNull);
    });
  });

  test('Book has value equality', () {
    expect(buildBook(), equals(buildBook()));
  });
}
