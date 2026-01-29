import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String username, String password);
  Future<User> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final responseData = response.data as Map<String, dynamic>;
      
      String accessToken = '';
      
      if (responseData.containsKey('accessToken')) {
        accessToken = responseData['accessToken'] as String;
      } else if (responseData.containsKey('token')) {
        accessToken = responseData['token'] as String;
      }
      
      if (accessToken.isEmpty) {
        throw Exception('No authentication token received');
      }
      
      return User.fromJson({
        ...responseData,
        'token': accessToken,
      });
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid username or password');
      } else if (e.response?.statusCode == 404) {
        throw Exception('API endpoint not found. Check base URL');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await dio.get(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final userData = response.data as Map<String, dynamic>;
      return User.fromJson({
        ...userData,
        'token': token,
      });
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid token format');
      } else {
        throw Exception('Failed to validate session: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to validate session: $e');
    }
  }
}