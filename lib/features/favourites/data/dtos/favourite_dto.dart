import 'dart:convert';

import '../../../../core/database/app_database.dart';

class FavouriteDto {
  const FavouriteDto({
    required this.key,
    required this.title,
    required this.authors,
    this.coverId,
    this.firstPublishYear,
  });

  final String key;
  final String title;
  final List<String> authors;
  final int? coverId;
  final int? firstPublishYear;

  factory FavouriteDto.fromMap(Map<String, Object?> map) {
    final rawAuthors = map[columnAuthors];
    final authors = rawAuthors is String && rawAuthors.isNotEmpty
        ? (jsonDecode(rawAuthors) as List).whereType<String>().toList(
            growable: false,
          )
        : const <String>[];

    return FavouriteDto(
      key: map[columnKey]! as String,
      title: map[columnTitle]! as String,
      authors: authors,
      coverId: map[columnCoverId] as int?,
      firstPublishYear: map[columnFirstPublishYear] as int?,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    columnKey: key,
    columnTitle: title,
    columnAuthors: jsonEncode(authors),
    columnCoverId: coverId,
    columnFirstPublishYear: firstPublishYear,
  };
}
