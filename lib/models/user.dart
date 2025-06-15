class User {
  String username;
  int userlevel;

  User({
    required this.username,
    required this.userlevel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      userlevel: json['userlevel'] as int,
    );
  }

  static List<User> fromJsonList(List<dynamic> json) {
    return json.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  User copyWith({
    String? username,
    int? userlevel,
  }) {
    return User(
      username: username ?? this.username,
      userlevel: userlevel ?? this.userlevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userlevel': userlevel,
    };
  }
}
