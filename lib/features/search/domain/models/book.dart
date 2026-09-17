import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book({
    required this.key,
    required this.title,
    required this.authorNames,
    this.coverId,
    this.firstPublishYear,
  });

  final String key;
  final String title;
  final List<String> authorNames;
  final int? coverId;
  final int? firstPublishYear;

  static const String unknownAuthor = 'Unknown author';
  static const String unknownYear = 'Year unknown';

  String get authorDisplay =>
      authorNames.isEmpty ? unknownAuthor : authorNames.join(', ');

  String get yearDisplay => firstPublishYear?.toString() ?? unknownYear;

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
