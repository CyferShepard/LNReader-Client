import 'source_filter_field.dart';

class Source {
  final String name;
  final List<SourceFilterField> filters;

  Source({
    required this.name,
    this.filters = const [],
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      name: json['name'] as String,
      filters:
          (json['filters'] as List<dynamic>?)?.map((e) => SourceFilterField.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  static List<Source> fromJsonList(List<dynamic> json) {
    return json.map((e) => Source.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'filters': filters.map((e) => e.toJson()).toList(),
      };
}
