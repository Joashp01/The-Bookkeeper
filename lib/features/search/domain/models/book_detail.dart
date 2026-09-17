import 'package:equatable/equatable.dart';

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

  String get descriptionDisplay => (description == null || description!.isEmpty)
      ? noDescription
      : description!;

  String? get coverUrl => (coverId == null || coverId! <= 0)
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
