import 'package:equatable/equatable.dart';

class Chapter extends Equatable {
  final String novelTitle;
  final String novelUrl;
  final String title;
  final String content;
  final String? previousPage;
  final String? nextPage;
  final String? url;

  const Chapter({
    required this.novelTitle,
    required this.novelUrl,
    required this.title,
    required this.content,
    this.previousPage,
    this.nextPage,
    this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'novelTitle': novelTitle,
      'novelUrl': novelUrl,
      'title': title,
      'content': content,
      'previousPage': previousPage,
      'nextPage': nextPage,
      'url': url,
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    String content = "";

    if (json['content'] is String) {
      // If content is a single string
      content = json['content'] as String;
    } else if (json['content'] is List) {
      // If content is an array, join it into a single string
      content = (json['content'] as List<dynamic>).join("\n");
    }

    return Chapter(
      novelTitle: json['novelTitle'],
      novelUrl: json['novelUrl'],
      title: json['title'],
      content: content,
      previousPage: json['previousPage'],
      nextPage: json['nextPage'],
      url: json['url'],
    );
  }

  @override
  List<Object?> get props => [novelTitle, novelUrl, title, content, previousPage, nextPage, url];
}
