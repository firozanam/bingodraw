import 'package:dio/dio.dart';
import '../config/app_config.dart';

class NetworkService {
  late final Dio _dio;
  
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  
  NetworkService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for authentication and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        // final token = AuthService().token;
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle common errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException();
          case DioExceptionType.badResponse:
            handleErrorResponse(e.response);
            break;
          default:
            throw NetworkException();
        }
        return handler.next(e);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  void handleErrorResponse(Response? response) {
    if (response == null) throw NetworkException();

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException();
      case 403:
        throw ForbiddenException();
      case 404:
        throw NotFoundException();
      default:
        throw NetworkException();
    }
  }
}

class TimeoutException implements Exception {}
class NetworkException implements Exception {}
class UnauthorizedException implements Exception {}
class ForbiddenException implements Exception {}
class NotFoundException implements Exception {}