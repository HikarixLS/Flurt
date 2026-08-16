import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final Map<String, dynamic> _simpleMemoryCache = {};

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'FlurtMovieApp/1.0',
        },
      ),
    );

    // Logging & interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool enableCache = true,
  }) async {
    final cacheKey = '$path?${queryParameters?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? ''}';

    if (enableCache && _simpleMemoryCache.containsKey(cacheKey)) {
      return _simpleMemoryCache[cacheKey];
    }

    final response = await dio.get(path, queryParameters: queryParameters);
    if (enableCache && response.statusCode == 200) {
      _simpleMemoryCache[cacheKey] = response.data;
    }
    return response.data;
  }
}
