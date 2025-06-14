class SearchResult {
  String url;
  String title;
  String summary;
  String cover;
  List<String> genres;
  int? chapterCount;

  SearchResult({
    required this.url,
    required this.title,
    required this.summary,
    required this.cover,
    required this.genres,
    this.chapterCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'summary': summary,
      'cover': cover,
      'genres': genres,
      'chapterCount': chapterCount,
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];
    if (json['genres'] is List) {
      genres = (json['genres'] as List<dynamic>).map((e) => e.toString()).toList();
    } else if (json['genres'] is String) {
      genres = [json['genres'] as String];
    }
    return SearchResult(
      url: (json['url'] ?? json['path']) as String? ?? '',
      title: (json['title'] ?? json['name']) as String? ?? 'Unknown Title',
      summary: json['summary'] as String? ?? 'No summary available.',
      cover: json['cover'] as String? ?? '',
      genres: genres,
      chapterCount: json['chapterCount'] as int?,
    );
  }

  static List<SearchResult> fromJsonList(List<dynamic> json) {
    return json.map((e) => SearchResult.fromJson(e as Map<String, dynamic>)).toList();
  }
}
