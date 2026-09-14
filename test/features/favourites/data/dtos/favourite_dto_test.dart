import 'package:bookshelf/core/database/app_database.dart';
import 'package:bookshelf/features/favourites/data/dtos/favourite_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toMap encodes authors as JSON and preserves fields', () {
    const dto = FavouriteDto(
      key: '/works/OL1W',
      title: 'Dune',
      authors: ['Frank Herbert', 'Kevin J. Anderson'],
      coverId: 111,
      firstPublishYear: 1965,
    );

    final map = dto.toMap();

    expect(map[columnKey], '/works/OL1W');
    expect(map[columnAuthors], '["Frank Herbert","Kevin J. Anderson"]');
    expect(map[columnCoverId], 111);
    expect(map[columnFirstPublishYear], 1965);
  });

  test('fromMap decodes the JSON authors and nullable fields', () {
    final dto = FavouriteDto.fromMap(<String, Object?>{
      columnKey: '/works/OL1W',
      columnTitle: 'Dune',
      columnAuthors: '["Frank Herbert"]',
      columnCoverId: null,
      columnFirstPublishYear: null,
    });

    expect(dto.authors, ['Frank Herbert']);
    expect(dto.coverId, isNull);
    expect(dto.firstPublishYear, isNull);
  });

  test('round-trips through toMap/fromMap', () {
    const original = FavouriteDto(
      key: '/works/OL1W',
      title: 'Dune',
      authors: ['Frank Herbert'],
      coverId: 111,
      firstPublishYear: 1965,
    );

    final restored = FavouriteDto.fromMap(original.toMap());

    expect(restored.key, original.key);
    expect(restored.title, original.title);
    expect(restored.authors, original.authors);
    expect(restored.coverId, original.coverId);
    expect(restored.firstPublishYear, original.firstPublishYear);
  });
}
