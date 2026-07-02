import 'package:light_novel_reader_client/models/search.dart';

class SourceSearch {
  final String source;
  final String query;
  Search? searchResult;

  SourceSearch({
    required this.source,
    required this.query,
    this.searchResult,
  });

  factory SourceSearch.fromJson(Map<String, dynamic> json) {
    if (json['source'] is! String || json['query'] is! String) {
      throw Exception('Invalid properties in JSON object');
    }
    return SourceSearch(
      source: json['source'],
      query: json['query'],
      searchResult: json['searchResult'] != null ? Search.fromJson(json['searchResult'] as Map<String, dynamic>) : null,
    );
  }

  static List<SourceSearch> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SourceSearch.fromJson(json as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'query': query,
      'searchResult': searchResult?.toJson(),
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<SourceSearch> list) {
    return list.map((item) => item.toJson()).toList();
  }
}
