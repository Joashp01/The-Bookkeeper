import 'package:bookshelf/features/search/data/dtos/book_dto.dart';
import 'package:bookshelf/features/search/data/mappers/book_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookDtoMapper.toDomain', () {
    test('transfers all fields onto the domain model', () {
      final book = const BookDto(
        key: '/works/OL1W',
        title: 'Dune',
        authorNames: ['Frank Herbert'],
        coverId: 42,
        firstPublishYear: 1965,
      ).toDomain();

      expect(book.key, '/works/OL1W');
      expect(book.title, 'Dune');
      expect(book.authorNames, ['Frank Herbert']);
      expect(book.coverId, 42);
      expect(book.firstPublishYear, 1965);
    });

    test('missing key becomes an empty string', () {
      final book = const BookDto(
        key: null,
        title: 'x',
        authorNames: [],
        coverId: null,
        firstPublishYear: null,
      ).toDomain();
      expect(book.key, '');
    });

    test('missing or blank title becomes "Untitled"', () {
      final fromNull = const BookDto(
        key: 'k',
        title: null,
        authorNames: [],
        coverId: null,
        firstPublishYear: null,
      ).toDomain();
      final fromEmpty = const BookDto(
        key: 'k',
        title: '',
        authorNames: [],
        coverId: null,
        firstPublishYear: null,
      ).toDomain();

      expect(fromNull.title, 'Untitled');
      expect(fromEmpty.title, 'Untitled');
    });
  });
}
