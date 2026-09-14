import 'package:bookshelf/features/search/data/dtos/work_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkDto.fromJson — description (F5)', () {
    test('a plain string is used as-is', () {
      final dto = WorkDto.fromJson(<String, dynamic>{
        'description': 'A great book.',
      });
      expect(dto.description, 'A great book.');
    });

    test('an object with a value key extracts the value', () {
      final dto = WorkDto.fromJson(<String, dynamic>{
        'description': <String, dynamic>{
          'type': '/type/text',
          'value': 'Nested description.',
        },
      });
      expect(dto.description, 'Nested description.');
    });

    test('an object without a string value yields null', () {
      final dto = WorkDto.fromJson(<String, dynamic>{
        'description': <String, dynamic>{'type': '/type/text'},
      });
      expect(dto.description, isNull);
    });

    test('absent description yields null', () {
      final dto = WorkDto.fromJson(<String, dynamic>{'title': 'x'});
      expect(dto.description, isNull);
    });
  });

  group('WorkDto.fromJson — subjects and covers', () {
    test('subjects list is kept, non-strings dropped', () {
      final dto = WorkDto.fromJson(<String, dynamic>{
        'subjects': <dynamic>['Fiction', 1, 'Adventure'],
      });
      expect(dto.subjects, ['Fiction', 'Adventure']);
    });

    test('absent subjects yields an empty list', () {
      final dto = WorkDto.fromJson(<String, dynamic>{'title': 'x'});
      expect(dto.subjects, isEmpty);
    });

    test('first cover id is taken from the covers array', () {
      final dto = WorkDto.fromJson(<String, dynamic>{
        'covers': <dynamic>[555, 666],
      });
      expect(dto.coverId, 555);
    });

    test('absent covers yields null', () {
      final dto = WorkDto.fromJson(<String, dynamic>{'title': 'x'});
      expect(dto.coverId, isNull);
    });
  });
}
