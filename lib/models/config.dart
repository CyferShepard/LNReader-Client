class Config {
  final String version;
  final String type;
  final String? url;

  Config({
    required this.version,
    required this.type,
    this.url,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      version: json['version'] as String,
      type: json['type'] as String,
      url: json['url'] as String?,
    );
  }

  static List<Config> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Config.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'type': type,
      'url': url,
    };
  }
}
