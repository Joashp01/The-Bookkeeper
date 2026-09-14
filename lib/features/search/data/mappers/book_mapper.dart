import '../../domain/models/book.dart';
import '../dtos/book_dto.dart';

/// Maps the parsed [BookDto] onto the immutable [Book] domain model.
///
/// Parsing safety already happened in the DTO; this layer only fills the two
/// remaining gaps a domain model must not expose: a missing key becomes empty,
/// and a missing/blank title becomes a readable placeholder.
extension BookDtoMapper on BookDto {
  Book toDomain() {
    final safeTitle = (title == null || title!.isEmpty) ? 'Untitled' : title!;
    return Book(
      key: key ?? '',
      title: safeTitle,
      authorNames: authorNames,
      coverId: coverId,
      firstPublishYear: firstPublishYear,
    );
  }
}
