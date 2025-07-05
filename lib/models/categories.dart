class Categories {
  final String name;
  final String username;
  final int position;

  Categories({
    required this.name,
    required this.username,
    this.position = 0,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      name: json['name'] as String,
      username: json['username'] as String,
      position: json['position'] as int,
    );
  }

  static List<Categories> fromJsonList(List<dynamic> json) {
    return json.map((e) => Categories.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'username': username,
        'position': position,
      };
}
