/// Raw data-layer representation of one entry in the search `docs` array.
///
/// [BookDto.fromJson] is the F5 defensive boundary: the Open Library response is
/// deliberately inconsistent, so every field is parsed without assuming its
/// presence or type. Nothing here throws on unexpected shapes.
class BookDto {
  const BookDto({
    required this.key,
    required this.title,
    required this.authorNames,
    required this.coverId,
    required this.firstPublishYear,
  });

  final String? key;
  final String? title;
  final List<String> authorNames;
  final int? coverId;
  final int? firstPublishYear;

  factory BookDto.fromJson(Map<String, dynamic> json) {
    return BookDto(
      key: json['key'] as String?,
      title: json['title'] as String?,
      authorNames: parseStringList(json['author_name']),
      coverId: parseInt(json['cover_i']),
      firstPublishYear: parseInt(json['first_publish_year']),
    );
  }

  /// `author_name` is usually a list, sometimes a bare string, sometimes absent.
  static List<String> parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    if (raw is String) {
      return [raw];
    }
    return const [];
  }

  /// `cover_i` / `first_publish_year` may be an int, a numeric string, or absent.
  static int? parseInt(dynamic raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is String) {
      return int.tryParse(raw);
    }
    return null;
  }
}
