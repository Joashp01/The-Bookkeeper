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
