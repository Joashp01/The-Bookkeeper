import 'package:bookshelf/features/search/data/dtos/book_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookDto.fromJson — F5 defensive mapping', () {
    test('parses a fully-populated doc', () {
      final dto = BookDto.fromJson(<String, dynamic>{
        'key': '/works/OL1W',
        'title': 'Dune',
        'author_name': <String>['Frank Herbert'],
        'cover_i': 12345,
        'first_publish_year': 1965,
      });

      expect(dto.key, '/works/OL1W');
      expect(dto.title, 'Dune');
      expect(dto.authorNames, ['Frank Herbert']);
      expect(dto.coverId, 12345);
      expect(dto.firstPublishYear, 1965);
    });

    group('author_name', () {
      test('a list is kept as-is', () {
        final dto = BookDto.fromJson(<String, dynamic>{
          'author_name': <String>['A', 'B'],
        });
        expect(dto.authorNames, ['A', 'B']);
      });

      test('absent yields an empty list (no crash)', () {
        final dto = BookDto.fromJson(<String, dynamic>{'title': 'x'});
        expect(dto.authorNames, isEmpty);
      });

      test('a bare string is wrapped into a single-element list', () {
        final dto = BookDto.fromJson(<String, dynamic>{'author_name': 'Solo'});
        expect(dto.authorNames, ['Solo']);
      });

      test('non-string entries in the list are dropped', () {
        final dto = BookDto.fromJson(<String, dynamic>{
          'author_name': <dynamic>['A', 42, null, 'B'],
        });
        expect(dto.authorNames, ['A', 'B']);
      });
    });

    group('cover_i', () {
      test('absent yields null (UI shows placeholder)', () {
        final dto = BookDto.fromJson(<String, dynamic>{'title': 'x'});
        expect(dto.coverId, isNull);
      });

      test('numeric string is coerced to int', () {
        final dto = BookDto.fromJson(<String, dynamic>{'cover_i': '777'});
        expect(dto.coverId, 777);
      });

      test('non-numeric value yields null', () {
        final dto = BookDto.fromJson(<String, dynamic>{'cover_i': 'abc'});
        expect(dto.coverId, isNull);
      });
    });

    group('first_publish_year', () {
      test('absent yields null', () {
        final dto = BookDto.fromJson(<String, dynamic>{'title': 'x'});
        expect(dto.firstPublishYear, isNull);
      });

      test('int is kept', () {
        final dto = BookDto.fromJson(<String, dynamic>{
          'first_publish_year': 2001,
        });
        expect(dto.firstPublishYear, 2001);
      });
    });

    test('title may be absent without crashing', () {
      final dto = BookDto.fromJson(<String, dynamic>{});
      expect(dto.title, isNull);
    });
  });
}
