import '../../domain/models/book_detail.dart';
import '../dtos/work_dto.dart';

extension WorkDtoMapper on WorkDto {
  BookDetail toDomain({
    List<String> authorNames = const [],
    int? firstPublishYear,
    int? fallbackCoverId,
  }) {
    final safeTitle = (title == null || title!.isEmpty) ? 'Untitled' : title!;
    return BookDetail(
      workId: extractWorkId(key),
      title: safeTitle,
      authorNames: authorNames,
      subjects: subjects,
      description: description,
      coverId: coverId ?? fallbackCoverId,
      firstPublishYear: firstPublishYear,
    );
  }
}

String extractWorkId(String? key) {
  if (key == null || key.isEmpty) {
    return '';
  }
  final segments = key.split('/').where((s) => s.isNotEmpty).toList();
  return segments.isEmpty ? '' : segments.last;
}
