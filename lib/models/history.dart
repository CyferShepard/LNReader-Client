import 'package:light_novel_reader_client/models/chapter_meta.dart';
import 'package:light_novel_reader_client/models/details.dart';

class History {
  String username;
  String source;
  String url;
  DateTime lastRead;
  int page;
  double position;
  ChapterMeta chapter;
  Details? novel;

  History({
    required this.username,
    required this.source,
    required this.url,
    required this.lastRead,
    required this.page,
    required this.position,
    required this.chapter,
    this.novel,
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
      chapter: ChapterMeta.fromJson(json['chapter'] as Map<String, dynamic>),
      novel: json['novel'] != null ? Details.fromJson(json['novel'] as Map<String, dynamic>) : null,
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
      'novel': novel?.toJson(),
    };
  }
}
