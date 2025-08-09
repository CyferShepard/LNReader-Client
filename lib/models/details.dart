import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/history.dart';

class Details {
  String? source;
  String? url;
  String? fullUrl;
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
  List<String> categories = [];

  Details({
    this.source,
    this.url,
    this.fullUrl,
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
    this.categories = const [],
  });

  History? get lastHistory => historyController.history
      .firstWhereOrNull((h) => h.novel.url == url && h.source == (source ?? apiController.currentSource));

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'url': url,
      'fullUrl': fullUrl,
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
      source: json['source'] as String?,
      url: json['url'] as String?,
      fullUrl: json['fullUrl'] as String?,
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
    String? source,
    String? url,
    String? fullUrl,
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
    List<String>? categories,
  }) {
    return Details(
      source: source ?? this.source,
      url: url ?? this.url,
      fullUrl: fullUrl ?? this.fullUrl,
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
      categories: categories ?? this.categories,
    );
  }
}
