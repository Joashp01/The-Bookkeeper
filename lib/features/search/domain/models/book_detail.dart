import 'package:equatable/equatable.dart';

/// Immutable domain model for the detail screen (Open Library works endpoint).
///
/// As with [Book], display fallbacks (F5) are centralised in the getters so the
/// detail screen never has to decide what to show for a missing field.
class BookDetail extends Equatable {
  const BookDetail({
    required this.workId,
    required this.title,
    required this.authorNames,
    required this.subjects,
    this.description,
    this.coverId,
    this.firstPublishYear,
  });

  /// Trailing segment of the work key, e.g. `OL45804W`.
  final String workId;
  final String title;
  final List<String> authorNames;
  final List<String> subjects;
  final String? description;
  final int? coverId;
  final int? firstPublishYear;

  static const String unknownAuthor = 'Unknown author';
  static const String unknownYear = 'Year unknown';
  static const String noDescription = 'No description available';

  String get authorDisplay =>
      authorNames.isEmpty ? unknownAuthor : authorNames.join(', ');

  String get yearDisplay => firstPublishYear?.toString() ?? unknownYear;

  /// Description text, or the fallback when it was absent or empty.
  String get descriptionDisplay =>
      (description == null || description!.isEmpty) ? noDescription : description!;

  String? get coverUrl => coverId == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

  @override
  List<Object?> get props => [
        workId,
        title,
        authorNames,
        subjects,
        description,
        coverId,
        firstPublishYear,
      ];
}
