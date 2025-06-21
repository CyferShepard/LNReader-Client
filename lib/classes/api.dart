import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:light_novel_reader_client/controller/server_controller.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/auth.dart';
import 'package:light_novel_reader_client/models/chapter.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/details.dart';
import 'package:light_novel_reader_client/models/favouriteWithNovelMeta.dart';
import 'package:light_novel_reader_client/models/history.dart';
import 'package:light_novel_reader_client/models/latest.dart';
import 'package:light_novel_reader_client/models/search_result.dart';
import 'package:light_novel_reader_client/models/user.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<ServerResponse> ping(Uri uri) async {
    try {
      uri = uri.replace(path: '/ping');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return ServerResponse(success: true, message: 'Server is reachable');
      } else {
        return ServerResponse(
          success: false,
          message: 'Server is not reachable. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Ping failed: $e');
      return ServerResponse(
        success: false,
        message: 'Server is not reachable. Error: $e',
      );
    }
  }

  Future<bool> canRegister() async {
    final response = await http.get(Uri.parse('$baseUrl/api/canRegister'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['canRegister'] as bool;
    } else {
      return false; // Default to false if the endpoint fails
    }
  }

  Future<bool?> toggleRegistration(bool enable) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/canRegister'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
      body: jsonEncode({'canRegister': enable}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['canRegister'] as bool;
    } else {
      return null; // Default to the requested state if the endpoint fails
    }
  }

  Future<Auth> login(Auth auth) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': auth.username, 'password': auth.password}),
    );
    if (response.statusCode == 200) {
      return auth.populateToken(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return auth.copyWith(
        status: false,
        errorMessage: 'Invalid username or password',
        token: null,
      );
    } else {
      return auth.copyWith(
        status: false,
        errorMessage: 'Failed to login: ${response.body}',
        token: null,
      );
    }
  }

  Future<Auth> register(Auth auth) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': auth.username, 'password': auth.password}),
    );
    if (response.statusCode == 200) {
      return auth.populateToken(jsonDecode(response.body));
    } else {
      return auth.copyWith(
        status: false,
        errorMessage: 'Error Updating Password',
        token: null,
      );
    }
  }

  Future<Auth> resetPassword(Auth auth, {String? username}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resetPassword'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
      body: jsonEncode({'password': auth.password, 'username': username}),
    );
    if (response.statusCode == 200) {
      return auth.populateToken(jsonDecode(response.body)).copyWith(status: true, errorMessage: '');
    } else {
      return auth.copyWith(
        status: false,
        errorMessage: response.reasonPhrase ?? 'Error Updating Password',
        token: null,
      );
    }
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'});
    if (response.statusCode == 200) {
      return User.fromJsonList(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print('Failed to fetch users: ${response.body}');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateSources() async {
    final response = await http.get(Uri.parse('$baseUrl/api/updatePlugins'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to update sources: ${response.body}');
    }
  }

  Future<List<String>> getSources() async {
    final response = await http.get(Uri.parse('$baseUrl/api/sources'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'});
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).cast<String>();
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to fetch sources: ${response.body}');
    }
  }

  Future<List<SearchResult>> search(String searchTerm, String source) async {
    if (searchTerm.length < 3) {
      return [];
    }
    final response = await http.post(Uri.parse('$baseUrl/api/search'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
        body: jsonEncode({'searchTerm': searchTerm, 'source': source}));
    if (response.statusCode == 200) {
      return SearchResult.fromJsonList(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to search: ${response.body}');
    }
  }

  Future<Details> getDetails(
    String url,
    String source, {
    bool refresh = false,
    required bool canCacheNovel,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/novel'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
      body: jsonEncode({'source': source, 'url': url, 'clearCache': refresh, "cacheData": canCacheNovel}),
    );
    if (response.statusCode == 200) {
      final details = Details.fromJson(jsonDecode(response.body));
      return details;
    } else if (response.statusCode == 404) {
      throw Exception('Details not found.');
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to fetch details: ${response.body}');
    }
  }

  Future<Chapters> getChapters(
    String url,
    String source,
    Map<String, String>? additionalProps, {
    bool refresh = false,
    required bool canCacheChapters,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chapters'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
      body: jsonEncode({
        'source': source,
        'url': url,
        'additionalProps': additionalProps,
        "clearCache": refresh,
        "cacheData": canCacheChapters
      }),
    );
    if (response.statusCode == 200) {
      // print(response.body);
      return Chapters.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Chapters not found.');
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to fetch chapters: ${response.body}');
    }
  }

  Future<Chapter> getChapter(String url, String source) async {
    final response = await http.post(Uri.parse('$baseUrl/api/chapter'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
        body: jsonEncode({'url': url, 'source': source}));
    if (response.statusCode == 200) {
      return Chapter.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Chapter not found.');
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to fetch chapter: ${response.body}');
    }
  }

  Future<Latest?> getLatest(String source, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/latest?source=$source&page=$page'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${authController.auth.token}'},
    );
    if (response.statusCode == 200) {
      return Latest.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print('Failed to fetch latest: ${response.body}');
      return null;
    }
  }

  Future<List<FavouriteWithNovelMeta>> getFavourites({String? url, String? source}) async {
    String apiUrl = '$baseUrl/favourites/get';
    if (url != null && source != null) {
      apiUrl += '?url=$url&source=$source';
    }
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.auth.token}',
    });
    if (response.statusCode == 200) {
      return FavouriteWithNovelMeta.fromJsonList(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to fetch favourites: ${response.body}');
    }
  }

  Future<bool> addToFavourites(String source, Details novel) async {
    Map<String, dynamic> novelMeta = novel.toJson();
    novelMeta['source'] = source;
    final response = await http.post(
        Uri.parse(
          '$baseUrl/favourites/insert',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
        },
        body: jsonEncode({'novelMeta': novelMeta}));
    if (response.statusCode == 200) {
      // Handle the response as needed
      return true;
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print(Exception('Failed to add to favourites: ${response.body}'));
      return false;
    }
  }

  Future<bool> removeFromFavourites(String url, String source) async {
    final response = await http.delete(Uri.parse('$baseUrl/favourites/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
        },
        body: jsonEncode({'url': url, 'source': source}));
    if (response.statusCode == 200) {
      // Handle the response as needed
      return true;
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print(Exception('Failed to remove from favourites: ${response.body}'));
      return false;
    }
  }

  Future<List<History>> getHistory({String? url, String? novelUrl, String? source}) async {
    Uri uri = Uri.parse('$baseUrl/history/get');
    if (url != null && source != null) {
      uri = uri.replace(queryParameters: {'url': url, 'source': source});
    } else if (novelUrl != null && source != null) {
      uri = uri.replace(queryParameters: {'novelUrl': novelUrl, 'source': source});
    }
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
      },
    );
    if (response.statusCode == 200) {
      return History.fromJsonList(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to search: ${response.body}');
    }
  }

  Future<History?> addToHistory(
      {required Details novel,
      required ChapterListItem chapter,
      required String source,
      int page = 0,
      double position = 0.0}) async {
    Map<String, dynamic> novelMeta = novel.toJson();
    novelMeta['source'] = source;
    final response = await http.post(
      Uri.parse('$baseUrl/history/insert'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
      },
      body: jsonEncode({'novel': novelMeta, 'chapter': chapter.toJson(), 'page': page, 'position': position}),
    );
    if (response.statusCode == 200) {
      // Handle the response as needed

      return History.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print(Exception('Failed to add to history: ${response.body}'));
      return null;
    }
  }

  Future<List<History>?> markAsRead(
      {required Details novel,
      required List<ChapterListItem> chapters,
      required String source,
      int page = 0,
      double position = 0.0}) async {
    Map<String, dynamic> novelMeta = novel.toJson();
    novelMeta['source'] = source;
    final response = await http.post(
      Uri.parse('$baseUrl/history/insertBulk'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
      },
      body:
          jsonEncode({'novel': novelMeta, 'chapters': ChapterListItem.toJsonList(chapters), 'page': page, 'position': position}),
    );
    if (response.statusCode == 200) {
      // Handle the response as needed

      return History.fromJsonList(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print(Exception('Failed to add to history: ${response.body}'));
      return null;
    }
  }

  Future<bool> removeFromHistory(String url, String source) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/history/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
      },
      body: jsonEncode({'url': url, 'source': source}),
    );
    if (response.statusCode == 200) {
      // Handle the response as needed
      return true;
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      print(Exception('Failed to remove from history: ${response.body}'));
      return false;
    }
  }

  Future<void> getSourceIcon(String source) async {
    final response = await http.get(
      Uri.parse('$baseUrl/proxy/icon?source=$source'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
      },
    );
    if (response.statusCode == 200) {
      // Handle the response as needed

      return;
    } else {
      if (response.statusCode == 401 && authController.auth.isAuthenticated) {
        authController.logout(refreshLogin: true);
      }
      throw Exception('Failed to fetch source icon: ${response.body}');
    }
  }
}
