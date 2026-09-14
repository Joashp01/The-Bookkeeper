import 'book_dto.dart';

/// Data-layer representation of the `search.json` response envelope.
///
/// Defensive: `numFound` may be missing (falls back to the parsed doc count),
/// `docs` may be absent or contain non-object entries (those are skipped).
class SearchResponseDto {
  const SearchResponseDto({
    required this.numFound,
    required this.docs,
  });

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
