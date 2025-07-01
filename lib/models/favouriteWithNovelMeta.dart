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
  final String? lastUpdate;
  final Map<String, dynamic>? additionalProps;
  final int chapterCount;
  final int readCount;

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
    this.lastUpdate,
    this.additionalProps,
    this.chapterCount = 0,
    this.readCount = 0,
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
      'lastUpdate': lastUpdate ?? 'Unknown',
      'additionalProps': additionalProps ?? {},
      'chapterCount': chapterCount,
      'readCount': readCount,
    };
  }

  factory FavouriteWithNovelMeta.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];

    if (json['genres'] is String) {
      // If genres is a single string, split it into an array
      genres = (json['genres'] as String).split(',').map((e) => e.trim()).toList();
    } else if (json['genres'] is List) {
      // If genres is already an array, use it directly
      genres = (json['genres'] as List<dynamic>).cast<String>();
    }

    return FavouriteWithNovelMeta(
      dateAdded: DateTime.parse(json['date_added'] as String),
      source: json['source'] as String? ?? '',
      url: json['url'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      summary: json['summary'] as String? ?? 'No summary available.',
      author: json['author'] as String? ?? 'Unknown Author',
      status: json['status'] as String? ?? 'Unknown',
      genres: genres,
      lastUpdate: json['last_update'] as String? ?? 'Unknown',
      additionalProps: json['additionalProps'] != null ? Map<String, dynamic>.from(json['additionalProps'] as Map) : null,
      chapterCount: json['chapterCount'] as int? ?? 0,
      readCount: json['readCount'] as int? ?? 0,
    );
  }

  copyWith({
    DateTime? dateAdded,
    String? source,
    String? url,
    String? cover,
    String? title,
    String? summary,
    String? author,
    String? status,
    List<String>? genres,
    String? lastUpdate,
    Map<String, dynamic>? additionalProps,
    int? chapterCount,
    int? readCount,
  }) {
    return FavouriteWithNovelMeta(
      dateAdded: dateAdded ?? this.dateAdded,
      source: source ?? this.source,
      url: url ?? this.url,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      author: author ?? this.author,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      additionalProps: additionalProps ?? this.additionalProps,
      chapterCount: chapterCount ?? this.chapterCount,
      readCount: readCount ?? this.readCount,
    );
  }

  static List<FavouriteWithNovelMeta> fromJsonList(List<dynamic> json) {
    return json.map((e) => FavouriteWithNovelMeta.fromJson(e as Map<String, dynamic>)).toList();
  }
}
