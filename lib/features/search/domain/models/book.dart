import 'package:equatable/equatable.dart';

/// Immutable domain model for a single search result.
///
/// The model stores the *safely parsed* values (an author list that may be
/// empty, nullable cover id and year). The F5 "what does the UI show" decisions
/// live in the display getters below, centralised here so every screen renders a
/// missing field identically and each decision is unit-tested exactly once.
class Book extends Equatable {
  const Book({
    required this.key,
    required this.title,
    required this.authorNames,
    this.coverId,
    this.firstPublishYear,
  });

  /// Open Library work key, e.g. `/works/OL45804W`.
  final String key;
  final String title;
  final List<String> authorNames;
  final int? coverId;
  final int? firstPublishYear;

  static const String unknownAuthor = 'Unknown author';
  static const String unknownYear = 'Year unknown';

  /// Author line: joined names, or the fallback when `author_name` was absent.
  String get authorDisplay =>
      authorNames.isEmpty ? unknownAuthor : authorNames.join(', ');

  /// First publication year, or the fallback when it was absent.
  String get yearDisplay => firstPublishYear?.toString() ?? unknownYear;

  /// Cover image URL, or `null` when there is no usable cover (UI shows a
  /// placeholder in that case). Open Library omits `cover_i` for ~15% of results
  /// and also uses non-positive ids (e.g. `-1`) as a "no cover" sentinel, so we
  /// treat anything not strictly positive as absent to avoid a wasted 404.
  String? get coverUrl => (coverId == null || coverId! <= 0)
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

  @override
  List<Object?> get props => [
        key,
        title,
        authorNames,
        coverId,
        firstPublishYear,
      ];
}
