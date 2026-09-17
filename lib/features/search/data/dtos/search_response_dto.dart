import 'book_dto.dart';

class SearchResponseDto {
  const SearchResponseDto({required this.numFound, required this.docs});

  final int numFound;
  final List<BookDto> docs;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['docs'];
    final docs = rawDocs is List
        ? rawDocs
              .whereType<Map<String, dynamic>>()
              .map(BookDto.fromJson)
              .toList(growable: false)
        : const <BookDto>[];

    return SearchResponseDto(
      numFound: BookDto.parseInt(json['numFound']) ?? docs.length,
      docs: docs,
    );
  }
}
