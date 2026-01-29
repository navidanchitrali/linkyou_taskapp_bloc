import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

 

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await _secureStorage.read(key: AppConstants.authTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          
          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            await _secureStorage.write(
              key: AppConstants.authTokenKey,
              value: newAccessToken,
            );
            
            // Retry original request
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            return handler.resolve(await _dio.fetch(error.requestOptions));
          }
        } catch (e) {
          // Refresh failed, logout user
          await _secureStorage.delete(key: AppConstants.authTokenKey);
          await _secureStorage.delete(key: 'refresh_token');
          await _secureStorage.delete(key: 'user_data');
        }
      }
    }
    return handler.next(error);
  },
));
  }

  Dio get dio => _dio;
}