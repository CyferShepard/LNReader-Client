import 'package:light_novel_reader_client/models/search_result.dart';

class Latest {
  final List<SearchResult> results;
  final int? currentPage;
  final int? lastPage;

  Latest({
    required this.results,
    this.currentPage,
    this.lastPage,
  });
  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'currentPage': currentPage,
      'lastPage': lastPage,
    };
  }

  factory Latest.fromJson(Map<String, dynamic> json) {
    List<SearchResult> results = [];
    if (json['results'] is List) {
      results = (json['results'] as List<dynamic>).map((e) => SearchResult.fromJson(e as Map<String, dynamic>)).toList();
    }
    return Latest(
      results: results,
      currentPage: json['currentPage'] as int?,
      lastPage: json['lastPage'] as int?,
    );
  }

  static List<Latest> fromJsonList(List<dynamic> json) {
    return json.map((e) => Latest.fromJson(e as Map<String, dynamic>)).toList();
  }
}
