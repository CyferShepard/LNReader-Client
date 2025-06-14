class Details {
  String? url;
  String? cover;
  String title;
  String summary;
  List<String> tags;
  String author;
  String status;
  List<String> genre;
  String chapters;
  String lastUpdate;
  Map<String, String> additionalProps;

  Details({
    this.url,
    this.cover,
    required this.title,
    required this.summary,
    this.tags = const [],
    this.author = "",
    this.status = "Unknown",
    this.genre = const [],
    this.chapters = "0",
    this.lastUpdate = "Unknown",
    this.additionalProps = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'cover': cover,
      'title': title,
      'summary': summary,
      'tags': tags,
      'author': author,
      'status': status,
      'genres': genre,
      'chapters': chapters,
      'lastUpdate': lastUpdate,
      'additionalProps': additionalProps,
    };
  }

  factory Details.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];
    String? summary = "";

    if (json['genres'] is String) {
      // If genres is a single string, split it into an array
      genres = (json['genres'] as String).split(',').map((e) => e.trim()).toList();
    } else if (json['genres'] is List) {
      // If genres is already an array, use it directly
      genres = (json['genres'] as List<dynamic>).cast<String>();
    }

    if (json['summary'] is String) {
      // If summary is a single string, split it into an array
      summary = (json['summary'] as String);
    } else if (json['summary'] is List) {
      // If genres is already an array, use it directly
      summary = (json['summary'] as List<dynamic>).cast<String>().join("\n");
    }

    return Details(
      url: json['url'] as String?,
      cover: json['cover'] as String? ?? "",
      title: json['title'] as String,
      summary: summary,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      author: json['author'] as String? ?? "",
      status: json['status'] as String? ?? "Unknown",
      genre: genres,
      chapters: json['chapters'] as String? ?? "0",
      lastUpdate: json['lastUpdate'] as String? ?? "Unknown",
      additionalProps:
          (json['additionalProps'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as String)) ?? {},
    );
  }

  Details copyWith({
    String? url,
    String? cover,
    String? title,
    String? summary,
    List<String>? tags,
    String? author,
    String? status,
    List<String>? genre,
    String? chapters,
    String? lastUpdate,
    Map<String, String>? additionalProps,
  }) {
    return Details(
      url: url ?? this.url,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      status: status ?? this.status,
      genre: genre ?? this.genre,
      chapters: chapters ?? this.chapters,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}
