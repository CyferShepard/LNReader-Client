import 'package:light_novel_reader_client/models/ScraperPayload.dart';

class Configs {
  String name;
  ScraperPayload config;

  Configs({
    required this.name,
    required this.config,
  });

  factory Configs.fromJson(Map<String, dynamic> json) {
    return Configs(
      name: json['name'] as String,
      config: ScraperPayload.fromJson(json['config'] as Map<String, dynamic>),
    );
  }

  static List<Configs> fromJsonList(Map<String, dynamic> json) {
    List<Configs> list = [];
    for (var item in json['files']) {
      list.add(Configs.fromJson(item as Map<String, dynamic>));
    }
    return list;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'config': config.toJson(),
    };
  }
}
