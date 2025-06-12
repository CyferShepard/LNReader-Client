import 'package:light_novel_reader_client/models/search_result.dart';

class HistoryChapter {
  int index;
  String title;
  String url;

  HistoryChapter({
    required this.index,
    required this.title,
    required this.url,
  });

  factory HistoryChapter.fromJson(Map<String, dynamic> json) {
    return HistoryChapter(
      index: json['index'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'title': title,
      'url': url,
    };
  }
}

class History {
  String username;
  String source;
  String url;
  DateTime lastRead;
  int page;
  double position;
  HistoryChapter chapter;
  SearchResult novel;

  History({
    required this.username,
    required this.source,
    required this.url,
    required this.lastRead,
    required this.page,
    required this.position,
    required this.chapter,
    required this.novel,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    double parsePosition(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return History(
      username: json['username'] as String,
      source: json['source'] as String,
      url: json['url'] as String,
      lastRead: DateTime.parse(json['last_read'] as String),
      page: json['page'] as int,
      position: parsePosition(json['position']),
      chapter: HistoryChapter.fromJson(json['chapter'] as Map<String, dynamic>),
      novel: SearchResult.fromJson(json['novel'] as Map<String, dynamic>),
    );
  }

  static List<History> fromJsonList(List<dynamic> json) {
    return json.map((e) => History.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'source': source,
      'url': url,
      'last_read': lastRead.toIso8601String(),
      'page': page,
      'position': position,
      'chapter': chapter.toJson(),
      'novel': novel.toJson(),
    };
  }
}
