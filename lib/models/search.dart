import 'package:light_novel_reader_client/models/search_result.dart';

class Search {
  final List<SearchResult> results;
  final int? currentPage;
  final int? lastPage;

  Search({
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

  factory Search.fromJson(Map<String, dynamic> json) {
    List<SearchResult> results = [];
    if (json['results'] is List) {
      results = (json['results'] as List<dynamic>).map((e) => SearchResult.fromJson(e as Map<String, dynamic>)).toList();
    }
    return Search(
      results: results,
      currentPage: json['currentPage'] as int?,
      lastPage: json['lastPage'] as int?,
    );
  }

  static List<Search> fromJsonList(List<dynamic> json) {
    return json.map((e) => Search.fromJson(e as Map<String, dynamic>)).toList();
  }
}
