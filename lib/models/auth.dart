import 'dart:convert';

class Auth {
  String? token;
  String? refreshToken;
  String username;
  String password;
  bool status;
  String errorMessage;

  Auth({
    this.token,
    this.refreshToken,
    required this.username,
    required this.password,
    this.status = false,
    this.errorMessage = '',
  });

  bool get isAuthenticated => token != null && refreshToken != null;
  bool get isAdmin {
    if (token == null || refreshToken == null) return false;
    final parts = token!.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final payloadBytes = base64Url.decode(normalized);
    final payloadString = utf8.decode(payloadBytes);
    final Map<String, dynamic> tokenJWT = jsonDecode(payloadString) as Map<String, dynamic>;
    // Adjust the path below if your JWT structure is different
    final userLevel = tokenJWT['user']?['userlevel'];
    return userLevel == 0;
  }

  Auth clear() {
    return Auth(
      token: null,
      refreshToken: null,
      username: '',
      password: '',
      status: false,
      errorMessage: '',
    );
  }

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      token: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      username: json['username'] as String,
      password: json['password'] as String,
      status: json['status'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': token,
      'refreshToken': refreshToken,
      'username': username,
      'password': '', // Password should not be stored in JSON
      'status': status,
      'errorMessage': errorMessage,
    };
  }

  Auth copyWith({
    String? token,
    String? refreshToken,
    String? username,
    String? password,
    bool? status,
    String? errorMessage,
  }) {
    return Auth(
      token: token != null ? (token == 'null' ? null : token) : this.token,
      refreshToken: refreshToken != null ? (refreshToken == 'null' ? null : refreshToken) : this.refreshToken,
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Auth populateToken(Map<String, dynamic> json) {
    return Auth(
      token: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      username: username,
      password: password,
      status: true,
      errorMessage: '',
    );
  }
}
