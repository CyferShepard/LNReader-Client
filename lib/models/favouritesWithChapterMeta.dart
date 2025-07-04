import 'package:light_novel_reader_client/models/chapter_meta.dart';
import 'package:light_novel_reader_client/models/details.dart';

class FavouriteWitChapterMeta extends Details {
  final ChapterMeta chapter;

  FavouriteWitChapterMeta({
    required super.source,
    required super.url,
    required super.cover,
    required super.title,
    required super.summary,
    super.author,
    super.status,
    super.genre,
    super.lastUpdate,
    super.additionalProps,
    required this.chapter,
  });

  factory FavouriteWitChapterMeta.fromJson(Map<String, dynamic> json) {
    Details details = Details.fromJson(json);
    return FavouriteWitChapterMeta(
      source: details.source,
      url: details.url,
      cover: details.cover,
      title: details.title,
      summary: details.summary,
      author: details.author,
      status: details.status,
      genre: details.genre,
      lastUpdate: details.lastUpdate,
      additionalProps: details.additionalProps,
      chapter: ChapterMeta.fromJson(json['chapter'] as Map<String, dynamic>),
    );
  }

  static List<FavouriteWitChapterMeta> fromJsonList(List<dynamic> json) {
    return json.map((e) => FavouriteWitChapterMeta.fromJson(e as Map<String, dynamic>)).toList();
  }
}
