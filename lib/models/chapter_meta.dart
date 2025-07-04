class ChapterMeta {
  final String source;
  final int chapterIndex;
  final String url;
  final String title;
  final String novelUrl;
  final DateTime dateAdded;

  ChapterMeta({
    required this.source,
    required this.chapterIndex,
    required this.url,
    required this.title,
    required this.novelUrl,
    required this.dateAdded,
  });

  factory ChapterMeta.fromJson(Map<String, dynamic> json) {
    return ChapterMeta(
      source: json['source'] as String,
      chapterIndex: json['chapterIndex'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
      novelUrl: json['novelUrl'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] ?? json['date_added']),
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        'chapterIndex': chapterIndex,
        'url': url,
        'title': title,
        'novelUrl': novelUrl,
        'dateAdded': dateAdded.toIso8601String(),
      };
}
