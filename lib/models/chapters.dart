class Chapters {
  List<ChapterListItem> chapters;
  int currentPage;
  int lastPage;

  Chapters({
    this.chapters = const [],
    this.currentPage = 0,
    this.lastPage = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      'currentPage': currentPage,
      'lastPage': lastPage,
    };
  }

  factory Chapters.fromJson(List<dynamic> json) {
    return Chapters(
      chapters: json
          .map((e) {
            try {
              return ChapterListItem.fromJson(Map<String, dynamic>.from(e as Map));
            } catch (_) {
              return ChapterListItem(
                source: '',
                url: '',
                title: 'Error parsing chapter',
                date: '',
                novelUrl: '',
              );
            }
          })
          .where((c) => c.url.isNotEmpty)
          .toList(),
    );
  }
}

class ChapterListItem {
  String source;
  String url;
  int index;
  String title;
  String date;
  String novelUrl;
  Map<String, dynamic>? additionalProps;

  ChapterListItem({
    required this.source,
    required this.url,
    this.index = 0,
    required this.title,
    required this.date,
    required this.novelUrl,
    this.additionalProps,
  });

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'url': url,
      'index': index,
      'title': title,
      'date': date,
      'novelUrl': novelUrl,
      'additionalProps': additionalProps,
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<ChapterListItem> items) {
    return items.map((item) => item.toJson()).toList();
  }

  factory ChapterListItem.fromJson(Map<String, dynamic> json) {
    return ChapterListItem(
        source: json['source'] as String,
        url: json['url'] as String,
        index: json['index'] as int? ?? 0,
        title: json['title'] as String,
        date: json['date'] as String? ?? '',
        novelUrl: json['novelUrl'] as String? ?? '',
        additionalProps: json['additionalProps'] as Map<String, dynamic>?);
  }
}
