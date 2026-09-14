import '../../domain/models/book_detail.dart';
import '../dtos/work_dto.dart';

/// Maps a [WorkDto] onto the [BookDetail] domain model.
///
/// The works endpoint does not return author names or the publication year, so
/// those are threaded through from the originating search [Book] via
/// [toDomain]'s parameters (defaulting to empty/absent when unavailable).
extension WorkDtoMapper on WorkDto {
  BookDetail toDomain({
    List<String> authorNames = const [],
    int? firstPublishYear,
  }) {
    final safeTitle = (title == null || title!.isEmpty) ? 'Untitled' : title!;
    return BookDetail(
      workId: extractWorkId(key),
      title: safeTitle,
      authorNames: authorNames,
      subjects: subjects,
      description: description,
      coverId: coverId,
      firstPublishYear: firstPublishYear,
    );
  }
}

/// Extracts the work id (trailing path segment) from an Open Library key.
///
/// `/works/OL45804W` → `OL45804W`. Returns an empty string for a null/empty or
/// malformed key rather than throwing.
String extractWorkId(String? key) {
  if (key == null || key.isEmpty) {
    return '';
  }
  final segments = key.split('/').where((s) => s.isNotEmpty).toList();
  return segments.isEmpty ? '' : segments.last;
}
