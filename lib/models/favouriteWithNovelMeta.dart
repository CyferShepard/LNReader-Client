class FavouriteWithNovelMeta {
  final DateTime dateAdded;
  final String source;
  final String url;
  final String cover;
  final String title;
  final String summary;
  final String author;
  final String status;
  final List<String> genres;

  FavouriteWithNovelMeta({
    required this.dateAdded,
    required this.source,
    required this.url,
    required this.cover,
    required this.title,
    required this.summary,
    required this.author,
    required this.status,
    required this.genres,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateAdded': dateAdded.toIso8601String(),
      'source': source,
      'url': url,
      'cover': cover,
      'title': title,
      'summary': summary,
      'author': author,
      'status': status,
      'genres': genres,
    };
  }

  factory FavouriteWithNovelMeta.fromJson(Map<String, dynamic> json) {
    return FavouriteWithNovelMeta(
      dateAdded: DateTime.parse(json['date_added'] as String),
      source: json['source'] as String? ?? '',
      url: json['url'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      summary: json['summary'] as String? ?? 'No summary available.',
      author: json['author'] as String? ?? 'Unknown Author',
      status: json['status'] as String? ?? 'Unknown',
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  static List<FavouriteWithNovelMeta> fromJsonList(List<dynamic> json) {
    return json.map((e) => FavouriteWithNovelMeta.fromJson(e as Map<String, dynamic>)).toList();
  }
}
