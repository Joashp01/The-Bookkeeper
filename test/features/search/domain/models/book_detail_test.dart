import 'package:bookshelf/features/search/domain/models/book_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BookDetail buildDetail({
    List<String> authorNames = const ['Frank Herbert'],
    String? description = 'A great book.',
    int? coverId = 12345,
    int? firstPublishYear = 1965,
  }) {
    return BookDetail(
      workId: 'OL1W',
      title: 'Dune',
      authorNames: authorNames,
      subjects: const ['Fiction'],
      description: description,
      coverId: coverId,
      firstPublishYear: firstPublishYear,
    );
  }

  group('BookDetail display decisions (F5)', () {
    test('authorDisplay falls back when there are no authors', () {
      expect(buildDetail(authorNames: const []).authorDisplay, 'Unknown author');
    });

    test('descriptionDisplay shows the description when present', () {
      expect(buildDetail().descriptionDisplay, 'A great book.');
    });

    test('descriptionDisplay falls back when absent', () {
      expect(
        buildDetail(description: null).descriptionDisplay,
        'No description available',
      );
    });

    test('descriptionDisplay falls back when empty', () {
      expect(
        buildDetail(description: '').descriptionDisplay,
        'No description available',
      );
    });

    test('yearDisplay falls back when the year is absent', () {
      expect(buildDetail(firstPublishYear: null).yearDisplay, 'Year unknown');
    });

    test('coverUrl is null when the cover is absent', () {
      expect(buildDetail(coverId: null).coverUrl, isNull);
    });
  });

  test('BookDetail has value equality', () {
    expect(buildDetail(), equals(buildDetail()));
  });
}
