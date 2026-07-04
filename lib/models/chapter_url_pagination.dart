class ChapterUrlPagination {
  String url;
  Map<String, dynamic> additionalProps;

  ChapterUrlPagination({
    required this.url,
    this.additionalProps = const {},
  });

  factory ChapterUrlPagination.fromJson(Map<String, dynamic> json) {
    return ChapterUrlPagination(
      url: json['url'] as String,
      additionalProps: json['additionalProps'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'additionalProps': additionalProps,
    };
  }
}
