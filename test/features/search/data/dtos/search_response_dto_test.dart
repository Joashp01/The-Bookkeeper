import 'package:bookshelf/features/search/data/dtos/search_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchResponseDto.fromJson', () {
    test('parses numFound and docs', () {
      final dto = SearchResponseDto.fromJson(<String, dynamic>{
        'numFound': 2,
        'docs': <dynamic>[
          <String, dynamic>{'title': 'A'},
          <String, dynamic>{'title': 'B'},
        ],
      });

      expect(dto.numFound, 2);
      expect(dto.docs, hasLength(2));
      expect(dto.docs.first.title, 'A');
    });

    test('empty docs array yields an empty result set', () {
      final dto = SearchResponseDto.fromJson(<String, dynamic>{
        'numFound': 0,
        'docs': <dynamic>[],
      });

      expect(dto.numFound, 0);
      expect(dto.docs, isEmpty);
    });

    test('absent docs yields an empty list (no crash)', () {
      final dto = SearchResponseDto.fromJson(<String, dynamic>{'numFound': 5});
      expect(dto.docs, isEmpty);
    });

    test('non-object doc entries are skipped', () {
      final dto = SearchResponseDto.fromJson(<String, dynamic>{
        'docs': <dynamic>[
          <String, dynamic>{'title': 'A'},
          'garbage',
          42,
        ],
      });
      expect(dto.docs, hasLength(1));
    });

    test('missing numFound falls back to the parsed doc count', () {
      final dto = SearchResponseDto.fromJson(<String, dynamic>{
        'docs': <dynamic>[
          <String, dynamic>{'title': 'A'},
        ],
      });
      expect(dto.numFound, 1);
    });
  });
}
