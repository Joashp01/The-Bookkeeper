import '../../domain/models/book.dart';
import '../dtos/book_dto.dart';

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
