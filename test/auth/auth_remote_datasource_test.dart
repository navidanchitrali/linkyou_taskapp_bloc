import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:your_app/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:your_app/features/auth/domain/entities/user.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late AuthRemoteDataSourceImpl authRemoteDataSource;

  final Map<String, dynamic> mockLoginResponse = {
    'id': 1,
    'username': 'testuser',
    'email': 'test@example.com',
    'firstName': 'Test',
    'lastName': 'User',
    'gender': 'male',
    'image': 'image_url',
    'accessToken': 'access_token_123',
    'refreshToken': 'refresh_token_123',
  };

  final Map<String, dynamic> mockUserResponse = {
    'id': 1,
    'username': 'testuser',
    'email': 'test@example.com',
    'firstName': 'Test',
    'lastName': 'User',
    'gender': 'male',
    'image': 'image_url',
  };

  setUp(() {
    mockDio = MockDio();
    authRemoteDataSource = AuthRemoteDataSourceImpl(dio: mockDio);
  });

  group('AuthRemoteDataSourceImpl - login', () {
    test('should login successfully with accessToken', () async {
      // Arrange
      final username = 'testuser';
      final password = 'password123';
      
      when(mockDio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: mockLoginResponse,
        requestOptions: RequestOptions(path: '/auth/login'),
      ));

      // Act
      final result = await authRemoteDataSource.login(username, password);

      // Assert
      expect(result, isA<User>());
      expect(result.username, 'testuser');
      expect(result.token, 'access_token_123');
      expect(result.refreshToken, 'refresh_token_123');
    });

    test('should login successfully with token field', () async {
      // Arrange
      final responseWithTokenField = {
        ...mockLoginResponse,
        'token': 'access_token_456',
      };
      responseWithTokenField.remove('accessToken');
      
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseWithTokenField,
        requestOptions: RequestOptions(path: '/auth/login'),
      ));

      // Act
      final result = await authRemoteDataSource.login('testuser', 'password');

      // Assert
      expect(result.token, 'access_token_456');
    });

    test('should throw exception when no token received', () async {
      // Arrange
      final responseWithoutToken = {
        'id': 1,
        'username': 'testuser',
      };
      
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseWithoutToken,
        requestOptions: RequestOptions(path: '/auth/login'),
      ));

      // Act & Assert
      expect(
        () => authRemoteDataSource.login('testuser', 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw specific error for 400 status', () async {
      // Arrange
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      ));

      // Act & Assert
      expect(
        () => authRemoteDataSource.login('testuser', 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw specific error for 404 status', () async {
      // Arrange
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      ));

      // Act & Assert
      expect(
        () => authRemoteDataSource.login('testuser', 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw connection timeout error', () async {
      // Arrange
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act & Assert
      expect(
        () => authRemoteDataSource.login('testuser', 'password'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRemoteDataSourceImpl - getCurrentUser', () {
    test('should get current user successfully', () async {
      // Arrange
      final token = 'valid_token';
      
      when(mockDio.get(
        '/auth/me',
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: mockUserResponse,
        requestOptions: RequestOptions(path: '/auth/me'),
      ));

      // Act
      final result = await authRemoteDataSource.getCurrentUser(token);

      // Assert
      expect(result, isA<User>());
      expect(result.username, 'testuser');
      expect(result.token, token);
    });

    test('should throw 401 error for expired session', () async {
      // Arrange
      final token = 'expired_token';
      
      when(mockDio.get(
        '/auth/me',
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/auth/me'),
        ),
      ));

      // Act & Assert
      expect(
        () => authRemoteDataSource.getCurrentUser(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw 400 error for invalid token', () async {
      // Arrange
      final token = 'invalid_token';
      
      when(mockDio.get(
        '/auth/me',
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/auth/me'),
        ),
      ));

      // Act & Assert
      expect(
        () => authRemoteDataSource.getCurrentUser(token),
        throwsA(isA<Exception>()),
      );
    });
  });
}