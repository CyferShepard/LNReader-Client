import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:light_novel_reader_client/controller/server_controller.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/auth.dart';
import 'package:light_novel_reader_client/models/categories.dart';
import 'package:light_novel_reader_client/models/chapter.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/details.dart';
import 'package:light_novel_reader_client/models/favouriteWithNovelMeta.dart';
import 'package:light_novel_reader_client/models/favouritesWithChapterMeta.dart';
import 'package:light_novel_reader_client/models/history.dart';
import 'package:light_novel_reader_client/models/latest.dart';
import 'package:light_novel_reader_client/models/search.dart';
import 'package:light_novel_reader_client/models/source.dart';
import 'package:light_novel_reader_client/models/source_search.dart';
import 'package:light_novel_reader_client/models/user.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function() requestFn,
  ) async {
    String? token = authController.auth.token;

    if (token == null) {
      // If no token is available, return an unauthorized response
      return http.Response('Unauthorized', 401);
    }
    http.Response response = await requestFn();

    if (response.statusCode == 401 && authController.auth.isAuthenticated) {
      // Try to refresh the token
      print('Token expired, refreshing...');
      bool refreshed = await _refreshToken();
      if (refreshed) {
        // Retry with new token
        token = authController.auth.token;
        response = await requestFn();
      } else {
        // If refresh fails, logout
        authController.logout();
      }
    }

    return response;
  }

  Future<bool> _refreshToken() async {
    String? refreshToken = authController.auth.refreshToken;
    if (refreshToken == null) {
      return false; // No refresh token available
    }
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': refreshToken}),
    );
    if (response.statusCode == 200) {
      print('Token Refreshed successfully');
      final data = jsonDecode(response.body);
      authController.auth.token = data['accessToken'];
      authController.auth.refreshToken = data['refreshToken'];
      authController.saveAuth();
      return true;
    }
    return false;
  }

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
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/api/canRegister'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'canRegister': enable}),
      );
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['canRegister'] as bool;
    } else {
      return null; // Default to the requested state if the endpoint fails
    }
  }

  Future<Auth> login(Auth auth) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept-Encoding': 'gzip, br'},
      body: jsonEncode({'username': auth.username, 'password': auth.password}),
    );
    if (response.statusCode == 200) {
      return auth.populateToken(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return auth.copyWith(
        status: false,
        errorMessage: 'Invalid username or password',
        token: 'null',
        refreshToken: 'null',
      );
    } else {
      return auth.copyWith(status: false, errorMessage: 'Failed to login: ${response.body}', token: 'null', refreshToken: 'null');
    }
  }

  Future<Auth> register(Auth auth) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json', 'Accept-Encoding': 'gzip, br'},
      body: jsonEncode({'username': auth.username, 'password': auth.password}),
    );
    if (response.statusCode == 200) {
      return auth.populateToken(jsonDecode(response.body));
    } else {
      return auth.copyWith(
        status: false,
        errorMessage: 'Error Updating Password',
        token: 'null',
        refreshToken: 'null',
      );
    }
  }

  Future<Auth> resetPassword(Auth auth, {String? username}) async {
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/auth/resetPassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'password': auth.password, 'username': username}),
      );
    });
    if (response.statusCode == 200) {
      return auth.populateToken(jsonDecode(response.body)).copyWith(status: true, errorMessage: '');
    } else {
      return auth.copyWith(
        status: false,
        errorMessage: response.reasonPhrase ?? 'Error Updating Password',
      );
    }
  }

  Future<List<User>> getUsers() async {
    final response = await _authorizedRequest(() {
      return http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
      );
    });
    if (response.statusCode == 200) {
      return User.fromJsonList(jsonDecode(response.body));
    } else {
      print('Failed to fetch users: ${response.body}');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateSources() async {
    final response = await _authorizedRequest(() {
      return http.get(Uri.parse('$baseUrl/api/updatePlugins'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
        'Accept-Encoding': 'gzip, br'
      });
    });
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update sources: ${response.body}');
    }
  }

  Future<List<Source>> getSources() async {
    final response = await _authorizedRequest(() {
      return http.get(Uri.parse('$baseUrl/api/sources'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
        'Accept-Encoding': 'gzip, br'
      });
    });
    if (response.statusCode == 200) {
      List<Source> sources = Source.fromJsonList(jsonDecode(response.body));

      return sources;
    } else {
      throw Exception('Failed to fetch sources: ${response.body}');
    }
  }

  Future<Search?> search(String source, {String? searchParams, int page = 1}) async {
    final response = await _authorizedRequest(() {
      return http.post(Uri.parse('$baseUrl/api/search'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.auth.token}',
            'Accept-Encoding': 'gzip, br'
          },
          body: jsonEncode({'source': source, 'searchParams': searchParams, "page": page}));
    });
    if (response.statusCode == 200) {
      return Search.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to search: ${response.body}');
    }
  }

  Future<List<SourceSearch>?> searchMultiple(List<SourceSearch> searchPayload) async {
    final response = await _authorizedRequest(() {
      return http.post(Uri.parse('$baseUrl/api/searchMultiple'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.auth.token}',
            'Accept-Encoding': 'gzip, br'
          },
          body: jsonEncode({'searchPayload': SourceSearch.toJsonList(searchPayload)}));
    });
    if (response.statusCode == 200) {
      return SourceSearch.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to search: ${response.body}');
    }
  }

  Future<Details> getDetails(
    String url,
    String source, {
    bool refresh = false,
    required bool canCacheNovel,
  }) async {
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/api/novel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'source': source, 'url': url, 'clearCache': refresh, "cacheData": canCacheNovel}),
      );
    });
    if (response.statusCode == 200) {
      final details = Details.fromJson(jsonDecode(response.body));
      return details;
    } else if (response.statusCode == 404) {
      throw Exception('Details not found.');
    } else {
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
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/api/chapters'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({
          'source': source,
          'url': url,
          'additionalProps': additionalProps,
          "clearCache": refresh,
          "cacheData": canCacheChapters
        }),
      );
    });
    if (response.statusCode == 200) {
      // print(response.body);
      return Chapters.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Chapters not found.');
    } else {
      throw Exception('Failed to fetch chapters: ${response.body}');
    }
  }

  Future<Chapter> getChapter(String url, String source) async {
    final response = await _authorizedRequest(() {
      return http.post(Uri.parse('$baseUrl/api/chapter'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.auth.token}',
            'Accept-Encoding': 'gzip, br'
          },
          body: jsonEncode({'url': url, 'source': source}));
    });
    if (response.statusCode == 200) {
      return Chapter.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Chapter not found.');
    } else {
      throw Exception('Failed to fetch chapter: ${response.body}');
    }
  }

  Future<Latest?> getLatest(String source, {int page = 1}) async {
    final response = await _authorizedRequest(() {
      return http.get(
        Uri.parse('$baseUrl/api/latest?source=$source&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
      );
    });
    if (response.statusCode == 200) {
      return Latest.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to fetch latest: ${response.body}');
      return null;
    }
  }

  Future<List<FavouriteWitChapterMeta>?> getLatestChapters() async {
    final response = await _authorizedRequest(() {
      return http.get(
        Uri.parse('$baseUrl/api/updates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
      );
    });
    if (response.statusCode == 200) {
      return FavouriteWitChapterMeta.fromJsonList(jsonDecode(response.body));
    } else {
      print('Failed to fetch latest: ${response.body}');
      return null;
    }
  }

  Future<List<FavouriteWithNovelMeta>> getFavourites({String? url, String? source}) async {
    String apiUrl = '$baseUrl/favourites/get';
    if (url != null && source != null) {
      apiUrl += '?url=$url&source=$source';
    }
    final response = await _authorizedRequest(() {
      return http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
        'Accept-Encoding': 'gzip, br'
      });
    });
    if (response.statusCode == 200) {
      return FavouriteWithNovelMeta.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch favourites: ${response.body}');
    }
  }

  Future<List<Categories>> getCategories() async {
    final response = await _authorizedRequest(() {
      return http.get(Uri.parse('$baseUrl/api/categories'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.auth.token}',
        'Accept-Encoding': 'gzip, br'
      });
    });
    if (response.statusCode == 200) {
      return Categories.fromJsonList(jsonDecode(response.body));
    } else {
      Categories defaultCategory = Categories(name: "All", position: -999, username: authController.auth.username);
      return [defaultCategory];
    }
  }

  Future<bool> updateFavouriteCategory(String url, String source, List<String> category) async {
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/favourites/setCategories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'url': url, 'source': source, 'categories': category}),
      );
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to update favourite category: ${response.body}'));
      return false;
    }
  }

  Future<bool> addCategory(String name) async {
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'name': name}),
      );
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to create category: ${response.body}'));
      return false;
    }
  }

  Future<bool> deleteCategory(String name) async {
    final response = await _authorizedRequest(() {
      return http.delete(
        Uri.parse('$baseUrl/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'name': name}),
      );
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to delete category: ${response.body}'));
      return false;
    }
  }

  Future<bool> addToFavourites(String source, Details novel) async {
    Map<String, dynamic> novelMeta = novel.toJson();
    novelMeta['source'] = source;
    final response = await _authorizedRequest(() {
      return http.post(
          Uri.parse(
            '$baseUrl/favourites/insert',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.auth.token}',
            'Accept-Encoding': 'gzip, br'
          },
          body: jsonEncode({'novelMeta': novelMeta}));
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to add to favourites: ${response.body}'));
      return false;
    }
  }

  Future<bool> removeFromFavourites(String url, String source) async {
    final response = await _authorizedRequest(() {
      return http.delete(Uri.parse('$baseUrl/favourites/delete'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.auth.token}',
            'Accept-Encoding': 'gzip, br'
          },
          body: jsonEncode({'url': url, 'source': source}));
    });
    if (response.statusCode == 200) {
      return true;
    } else {
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
    final response = await _authorizedRequest(() {
      return http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
      );
    });
    if (response.statusCode == 200) {
      return History.fromJsonList(jsonDecode(response.body));
    } else {
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
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/history/insert'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'novel': novelMeta, 'chapter': chapter.toJson(), 'page': page, 'position': position}),
      );
    });
    if (response.statusCode == 200) {
      return History.fromJson(jsonDecode(response.body));
    } else {
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
    final response = await _authorizedRequest(() {
      return http.post(
        Uri.parse('$baseUrl/history/insertBulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode(
            {'novel': novelMeta, 'chapters': ChapterListItem.toJsonList(chapters), 'page': page, 'position': position}),
      );
    });
    if (response.statusCode == 200) {
      return History.fromJsonList(jsonDecode(response.body));
    } else {
      print(Exception('Failed to add to history: ${response.body}'));
      return null;
    }
  }

  Future<bool> removeFromHistory(String url, String source) async {
    final response = await _authorizedRequest(() {
      return http.delete(
        Uri.parse('$baseUrl/history/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
        body: jsonEncode({'url': url, 'source': source}),
      );
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to remove from history: ${response.body}'));
      return false;
    }
  }

  Future<void> getSourceIcon(String source) async {
    final response = await _authorizedRequest(() {
      return http.get(
        Uri.parse('$baseUrl/proxy/icon?source=$source'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.auth.token}',
          'Accept-Encoding': 'gzip, br'
        },
      );
    });
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to fetch source icon: ${response.body}');
    }
  }
}
