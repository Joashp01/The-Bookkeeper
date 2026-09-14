/// Raw data-layer representation of the works endpoint (`/works/<id>.json`).
///
/// The interesting F5 case lives here: `description` is sometimes a plain
/// string, sometimes an object with a `value` key, and sometimes absent. All
/// three collapse to a nullable [String] without throwing.
class WorkDto {
  const WorkDto({
    required this.key,
    required this.title,
    required this.description,
    required this.subjects,
    required this.coverId,
  });

  final String? key;
  final String? title;
  final String? description;
  final List<String> subjects;
  final int? coverId;

  factory WorkDto.fromJson(Map<String, dynamic> json) {
    return WorkDto(
      key: json['key'] as String?,
      title: json['title'] as String?,
      description: parseDescription(json['description']),
      subjects: parseStringList(json['subjects']),
      coverId: parseFirstCover(json['covers']),
    );
  }

  /// `description`: string → itself; `{value: ...}` → the value; else null.
  static String? parseDescription(dynamic raw) {
    if (raw is String) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      final value = raw['value'];
      if (value is String) {
        return value;
      }
    }
    return null;
  }

  static List<String> parseStringList(dynamic raw) =>
      raw is List ? raw.whereType<String>().toList(growable: false) : const [];

  /// `covers` is an array of ids; take the first valid int, if any.
  static int? parseFirstCover(dynamic raw) {
    if (raw is List) {
      for (final item in raw) {
        if (item is int) {
          return item;
        }
      }
    }
    return null;
  }
}
