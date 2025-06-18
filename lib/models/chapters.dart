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
      chapters: json.map((e) => ChapterListItem.fromJson(e)).toList(),
    );
  }
}

class ChapterListItem {
  String url;
  int index;
  String title;
  String date;

  ChapterListItem({
    required this.url,
    this.index = 0,
    required this.title,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'index': index,
      'title': title,
      'date': date,
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<ChapterListItem> items) {
    return items.map((item) => item.toJson()).toList();
  }

  factory ChapterListItem.fromJson(Map<String, dynamic> json) {
    return ChapterListItem(
      url: json['url'] as String,
      index: json['index'] as int? ?? 0,
      title: json['title'] as String,
      date: json['date'] as String? ?? '',
    );
  }
}
