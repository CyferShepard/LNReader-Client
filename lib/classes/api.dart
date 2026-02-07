import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:light_novel_reader_client/classes/http_client.dart';
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
import 'package:light_novel_reader_client/models/pagination_wrapper.dart';
import 'package:light_novel_reader_client/models/search.dart';
import 'package:light_novel_reader_client/models/source.dart';
import 'package:light_novel_reader_client/models/source_search.dart';
import 'package:light_novel_reader_client/models/user.dart';

class ApiClient {
  final String baseUrl;
  late final HttpClient _httpClient;

  ApiClient({required this.baseUrl}) {
    _httpClient = HttpClient(baseUrl: baseUrl);
    _setupAuthInterceptor();
  }

  void _setupAuthInterceptor() {
    // Add auth interceptor for token refresh
    _httpClient.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = authController.auth.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && authController.auth.isAuthenticated) {
          print('Token expired, refreshing...');
          bool refreshed = await refreshToken();
          if (refreshed) {
            // Retry request with new token
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${authController.auth.token}';
            try {
              final response = await _httpClient.dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              return handler.reject(error);
            }
          } else {
            authController.logout();
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> refreshToken() async {
    String? refreshToken = authController.auth.refreshToken;
    if (refreshToken == null || authController.auth.status == false) {
      return false; // No refresh token available
    }
    try {
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
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
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

  Future<String?> getVersion() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/configs?type=web'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["version"] as String;
      } else {
        return null;
      }
    } catch (e) {
      print('Version fetch failed: $e');
      return null;
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
    final response = await _httpClient.post(
      '/api/canRegister',
      data: {'canRegister': enable},
    );

    if (response.statusCode == 200) {
      return response.data['canRegister'] as bool;
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
    final response = await _httpClient.post(
      '/auth/resetPassword',
      data: {'password': auth.password, 'username': username},
    );
    if (response.statusCode == 200) {
      return auth.populateToken(response.data).copyWith(status: true, errorMessage: '');
    } else {
      return auth.copyWith(
        status: false,
        errorMessage: response.statusMessage ?? 'Error Updating Password',
      );
    }
  }

  Future<List<User>> getUsers() async {
    final response = await _httpClient.get(
      '/api/users',
    );
    if (response.statusCode == 200) {
      return User.fromJsonList(response.data);
    } else {
      print('Failed to fetch users: ${response.data}');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateSources() async {
    final response = await _httpClient.get(
      '/api/updatePlugins',
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to update sources: ${response.data}');
    }
  }

  Future<List<Source>> getSources() async {
    final response = await _httpClient.get(
      '/api/sources',
    );

    if (response.statusCode == 200) {
      List<Source> sources = Source.fromJsonList(response.data);

      return sources;
    } else {
      throw Exception('Failed to fetch sources: ${response.data}');
    }
  }

  Future<Search?> search(String source, {String? searchParams, int page = 1}) async {
    final response = await _httpClient.post(
      '/api/search',
      data: {'source': source, 'searchParams': searchParams, 'page': page},
    );
    if (response.statusCode == 200) {
      return Search.fromJson(response.data);
    } else {
      throw Exception('Failed to search: ${response.data}');
    }
  }

  Future<List<SourceSearch>?> searchMultiple(List<SourceSearch> searchPayload) async {
    final response = await _httpClient.post(
      '/api/searchMultiple',
      data: {'searchPayload': SourceSearch.toJsonList(searchPayload)},
    );

    if (response.statusCode == 200) {
      return SourceSearch.fromJsonList(response.data);
    } else {
      throw Exception('Failed to search: ${response.data}');
    }
  }

  Future<Details> getDetails(
    String url,
    String source, {
    bool refresh = false,
    required bool canCacheNovel,
  }) async {
    final response = await _httpClient.post(
      '/api/novel',
      data: {'source': source, 'url': url, 'clearCache': refresh, "cacheData": canCacheNovel},
      useCache: !refresh,
    );

    if (response.statusCode == 200) {
      final details = Details.fromJson(response.data);
      return details;
    } else if (response.statusCode == 404) {
      throw Exception('Details not found.');
    } else {
      throw Exception('Failed to fetch details: ${response.data}');
    }
  }

  Future<Chapters> getChapters(
    String url,
    String source,
    Map<String, String>? additionalProps, {
    bool refresh = false,
    required bool canCacheChapters,
  }) async {
    final response = await _httpClient.post(
      '/api/chapters',
      data: {
        'source': source,
        'url': url,
        'additionalProps': additionalProps,
        "clearCache": refresh,
        "cacheData": canCacheChapters
      },
      useCache: !refresh,
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return Chapters.fromJson(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Chapters not found.');
    } else {
      throw Exception('Failed to fetch chapters: ${response.data}');
    }
  }

  Future<Chapter> getChapter(String url, String source) async {
    final response = await _httpClient.post('/api/chapter', data: {'url': url, 'source': source}, useCache: true);

    if (response.statusCode == 200) {
      return Chapter.fromJson(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Chapter not found.');
    } else {
      throw Exception('Failed to fetch chapter: ${response.data}');
    }
  }

  Future<Latest?> getLatest(String source, {int page = 1}) async {
    final response = await _httpClient.get(
      '/api/latest',
      queryParameters: {'source': source, 'page': page},
    );

    if (response.statusCode == 200) {
      return Latest.fromJson(response.data);
    } else {
      print('Failed to fetch latest: ${response.data}');
      return null;
    }
  }

  Future<PaginationWrapper<FavouriteWitChapterMeta>> getLatestChapters({int page = 1, int pageSize = 10}) async {
    final response = await _httpClient.get(
      '/api/updates',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    if (response.statusCode == 200) {
      try {
        PaginationWrapper<FavouriteWitChapterMeta> wrapper = PaginationWrapper<FavouriteWitChapterMeta>(
          results: FavouriteWitChapterMeta.fromJsonList(response.data["results"]),
          page: response.data['page'] ?? 1,
          pageSize: response.data['pageSize'] ?? 10,
          totalCount: response.data['totalCount'] ?? 0,
          totalPages: response.data['totalPages'] ?? 1,
        );
        return wrapper;
      } catch (e) {
        print('Error parsing latest chapters: $e');
        return PaginationWrapper<FavouriteWitChapterMeta>.empty();
      }
      // return FavouriteWitChapterMeta.fromJsonList(response.data);
    } else {
      print('Failed to fetch latest: ${response.data}');
      return PaginationWrapper<FavouriteWitChapterMeta>.empty();
    }
  }

  Future<List<FavouriteWithNovelMeta>> getFavourites({String? url, String? source}) async {
    Map<String, dynamic>? queryParameters = url != null && source != null ? {'url': url, 'source': source} : null;

    try {
      final response = await _httpClient.get('/favourites/get', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return FavouriteWithNovelMeta.fromJsonList(response.data);
      } else {
        throw Exception('Failed to fetch favourites: ${response.data}');
      }
    } catch (e) {
      print('Error fetching favourites: $e');
      throw Exception('Failed to fetch favourites: $e');
    }
  }

  Future<List<Categories>> getCategories() async {
    final response = await _httpClient.get(
      '/api/categories',
    );

    if (response.statusCode == 200) {
      return Categories.fromJsonList(response.data);
    } else {
      Categories defaultCategory = Categories(name: "All", position: -999, username: authController.auth.username);
      return [defaultCategory];
    }
  }

  Future<bool> updateFavouriteCategory(String url, String source, List<String> category) async {
    final response = await _httpClient.post(
      '/favourites/setCategories',
      data: {'url': url, 'source': source, 'categories': category},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to update favourite category: ${response.data}'));
      return false;
    }
  }

  Future<bool> addCategory(String name) async {
    final response = await _httpClient.post(
      '/api/categories',
      data: {'name': name},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to create category: ${response.data}'));
      return false;
    }
  }

  Future<bool> deleteCategory(String name) async {
    final response = await _httpClient.delete(
      '/api/categories',
      data: {'name': name},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to delete category: ${response.data}'));
      return false;
    }
  }

  Future<bool> addToFavourites(String source, Details novel) async {
    Map<String, dynamic> novelMeta = novel.toJson();
    novelMeta['source'] = source;

    final response = await _httpClient.post(
      '/favourites/insert',
      data: {'novelMeta': novelMeta},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to add to favourites: ${response.data}'));
      return false;
    }
  }

  Future<bool> removeFromFavourites(String url, String source) async {
    final response = await _httpClient.delete(
      '/favourites/delete',
      data: {'url': url, 'source': source},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to remove from favourites: ${response.data}'));
      return false;
    }
  }

  Future<List<History>> getHistory({String? url, String? novelUrl, String? source}) async {
    final response = await _httpClient.get(
      '/history/get',
      queryParameters: url != null && source != null
          ? {'url': url, 'source': source}
          : novelUrl != null && source != null
              ? {'novelUrl': novelUrl, 'source': source}
              : null,
    );

    if (response.statusCode == 200) {
      return History.fromJsonList(response.data);
    } else {
      throw Exception('Failed to search: ${response.data}');
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

    final response = await _httpClient.post(
      '/history/insert',
      data: {'novel': novelMeta, 'chapter': chapter.toJson(), 'page': page, 'position': position},
    );

    if (response.statusCode == 200) {
      return History.fromJson(response.data);
    } else {
      print(Exception('Failed to add to history: ${response.data}'));
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
    final response = await _httpClient.post(
      '/history/insertBulk',
      data: {'novel': novelMeta, 'chapters': ChapterListItem.toJsonList(chapters), 'page': page, 'position': position},
    );

    if (response.statusCode == 200) {
      return History.fromJsonList(response.data);
    } else {
      print(Exception('Failed to add to history: ${response.data}'));
      return null;
    }
  }

  Future<bool> removeFromHistory(String url, String source) async {
    final response = await _httpClient.delete(
      '/history/delete',
      data: {'url': url, 'source': source},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(Exception('Failed to remove from history: ${response.data}'));
      return false;
    }
  }

  Future<void> getSourceIcon(String source) async {
    final response = await _httpClient.get(
      '/proxy/icon',
      queryParameters: {'source': source},
      useCache: true,
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to fetch source icon: ${response.data}');
    }
  }
}
