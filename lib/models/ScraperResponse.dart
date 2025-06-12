class ScraperResponse {
  String url;
  List<Map<String, dynamic>> results;

  ScraperResponse({
    required this.url,
    required this.results,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'results': results,
    };
  }

  factory ScraperResponse.fromJson(Map<String, dynamic> json) {
    return ScraperResponse(
      url: json['url'] as String,
      results: List<Map<String, dynamic>>.from(json['results'] as List),
    );
  }
}
