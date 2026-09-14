import 'package:bookshelf/features/search/data/dtos/work_dto.dart';
import 'package:bookshelf/features/search/data/mappers/work_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractWorkId', () {
    test('takes the trailing segment of a works key', () {
      expect(extractWorkId('/works/OL45804W'), 'OL45804W');
    });

    test('handles a key without a leading slash', () {
      expect(extractWorkId('works/OL1W'), 'OL1W');
    });

    test('returns empty string for null or empty key', () {
      expect(extractWorkId(null), '');
      expect(extractWorkId(''), '');
    });
  });

  group('WorkDtoMapper.toDomain', () {
    const dto = WorkDto(
      key: '/works/OL1W',
      title: 'Dune',
      description: 'A great book.',
      subjects: ['Fiction'],
      coverId: 42,
    );

    test('maps work fields and extracts the work id', () {
      final detail = dto.toDomain();

      expect(detail.workId, 'OL1W');
      expect(detail.title, 'Dune');
      expect(detail.subjects, ['Fiction']);
      expect(detail.description, 'A great book.');
      expect(detail.coverId, 42);
    });

    test('threads author names and year from the search result', () {
      final detail = dto.toDomain(
        authorNames: const ['Frank Herbert'],
        firstPublishYear: 1965,
      );

      expect(detail.authorNames, ['Frank Herbert']);
      expect(detail.firstPublishYear, 1965);
    });

    test('defaults author names to empty and year to null', () {
      final detail = dto.toDomain();

      expect(detail.authorNames, isEmpty);
      expect(detail.firstPublishYear, isNull);
    });

    test('missing or blank title becomes "Untitled"', () {
      final detail = const WorkDto(
        key: '/works/OL1W',
        title: null,
        description: null,
        subjects: [],
        coverId: null,
      ).toDomain();
      expect(detail.title, 'Untitled');
    });
  });
}
