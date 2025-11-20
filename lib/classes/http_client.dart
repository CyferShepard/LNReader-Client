import 'dart:convert';

import 'package:dio/dio.dart';

class CacheEntry {
  final Response response;
  final DateTime timestamp;
  final Duration maxAge;

  CacheEntry({
    required this.response,
    required this.timestamp,
    required this.maxAge,
  });

  bool get isExpired {
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

class CacheInterceptor extends Interceptor {
  final Map<String, CacheEntry> _cache = {};
  static const Duration _defaultMaxAge = Duration(minutes: 5);

  // Generate cache key from request
  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final method = options.method;
    final bodyHash = options.data != null ? jsonEncode(options.data).hashCode : 0;
    return '$method-$uri-$bodyHash';
  }

  // Get cached response if available and not expired
  Response? _getCached(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.response;
  }

  // Store response in cache
  void _setCache(String key, Response response, Duration maxAge) {
    _cache[key] = CacheEntry(
      response: response,
      timestamp: DateTime.now(),
      maxAge: maxAge,
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if caching is enabled for this request
    final useCache = options.extra['useCache'] as bool? ?? false;
    final forceRefresh = options.extra['forceRefresh'] as bool? ?? false;

    if (!useCache || forceRefresh) {
      return handler.next(options);
    }

    // Check for cached response
    final cacheKey = _generateCacheKey(options);
    final cachedResponse = _getCached(cacheKey);

    if (cachedResponse != null) {
      print('Cache hit: $cacheKey');
      // Return cached response
      return handler.resolve(
        Response(
          requestOptions: options,
          data: cachedResponse.data,
          statusCode: cachedResponse.statusCode,
          statusMessage: cachedResponse.statusMessage,
          headers: Headers.fromMap({
            ...cachedResponse.headers.map,
            'x-cache': ['HIT'],
          }),
          extra: cachedResponse.extra,
        ),
      );
    }

    print('Cache miss: $cacheKey');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if we should cache this response
    final useCache = response.requestOptions.extra['useCache'] as bool? ?? false;
    final forceRefresh = response.requestOptions.extra['forceRefresh'] as bool? ?? false;

    if (useCache && !forceRefresh && response.statusCode == 200) {
      final cacheDuration = response.requestOptions.extra['cacheDuration'] as Duration? ?? _defaultMaxAge;
      final cacheKey = _generateCacheKey(response.requestOptions);
      _setCache(cacheKey, response, cacheDuration);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Invalidate cache on error (optional)
    final invalidateOnError = err.requestOptions.extra['invalidateOnError'] as bool? ?? false;

    if (invalidateOnError) {
      final cacheKey = _generateCacheKey(err.requestOptions);
      _cache.remove(cacheKey);
    }

    handler.next(err);
  }

  // Clear specific cache entry
  void clearCache(String pattern) {
    _cache.removeWhere((key, value) => key.contains(pattern));
  }

  // Clear all cache
  void clearAllCache() {
    _cache.clear();
  }

  // Clear expired cache entries
  void cleanupExpiredCache() {
    _cache.removeWhere((key, value) => value.isExpired);
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final total = _cache.length;
    final expired = _cache.values.where((entry) => entry.isExpired).length;

    return {
      'total': total,
      'valid': total - expired,
      'expired': expired,
    };
  }

  // Get all cache keys
  List<String> getCacheKeys() {
    return _cache.keys.toList();
  }
}

class HttpClient {
  late final Dio _dio;
  late final CacheInterceptor _cacheInterceptor;

  HttpClient({required String baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept-Encoding': 'gzip, br',
      },
    ));

    _cacheInterceptor = CacheInterceptor();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Add cache interceptor
    _dio.interceptors.add(_cacheInterceptor);

    // Add logging interceptor (optional)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false,
      logPrint: (obj) => print(obj),
    ));
  }

  // Add auth token to requests
  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // GET request with caching options
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = false,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {
          'useCache': useCache,
          'forceRefresh': forceRefresh,
          'cacheDuration': cacheDuration,
        },
      ),
    );
  }

  // POST request with caching options
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = true,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {
          'useCache': useCache,
          'forceRefresh': forceRefresh,
          'cacheDuration': cacheDuration,
        },
      ),
    );
  }

  // PUT request (invalidates cache)
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request (invalidates cache)
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Cache management methods
  void clearCache(String pattern) {
    _cacheInterceptor.clearCache(pattern);
  }

  void clearAllCache() {
    _cacheInterceptor.clearAllCache();
  }

  void cleanupCache() {
    _cacheInterceptor.cleanupExpiredCache();
  }

  Map<String, dynamic> getCacheStats() {
    return _cacheInterceptor.getCacheStats();
  }

  List<String> getCacheKeys() {
    return _cacheInterceptor.getCacheKeys();
  }

  // Access to underlying Dio instance
  Dio get dio => _dio;
}
