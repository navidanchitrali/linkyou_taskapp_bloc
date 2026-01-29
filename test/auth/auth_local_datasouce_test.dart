import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:linkyou_tasks_app/features/auth/domain/entities/user.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
 

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthLocalDataSourceImpl authLocalDataSource;

  final User mockUser = User(
    id: '1',
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    gender: 'male',
    image: 'image_url',
    token: 'access_token_123',
    refreshToken: 'refresh_token_123',
  );

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    authLocalDataSource = AuthLocalDataSourceImpl(
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthLocalDataSourceImpl - Token Operations', () {
    test('should save token successfully', () async {
      // Arrange
      final token = 'test_token';
      when(mockSecureStorage.write(
        key: 'access_token',
        value: token,
      )).thenAnswer((_) async => Future.value());

      // Act
      await authLocalDataSource.saveToken(token);

      // Assert
      verify(mockSecureStorage.write(
        key: 'access_token',
        value: token,
      )).called(1);
    });

    test('should get saved token', () async {
      // Arrange
      final token = 'test_token';
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => token);

      // Act
      final result = await authLocalDataSource.getToken();

      // Assert
      expect(result, token);
    });

    test('should return null when no token saved', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      // Act
      final result = await authLocalDataSource.getToken();

      // Assert
      expect(result, isNull);
    });

    test('should return null for empty token', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => '');

      // Act
      final result = await authLocalDataSource.getToken();

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthLocalDataSourceImpl - User Operations', () {
    test('should save user with all data', () async {
      // Arrange
      when(mockSecureStorage.write(any, any))
          .thenAnswer((_) async => Future.value());

      // Act
      await authLocalDataSource.saveUser(mockUser);

      // Assert
      verify(mockSecureStorage.write(
        key: 'access_token',
        value: 'access_token_123',
      )).called(1);
      
      verify(mockSecureStorage.write(
        key: 'refresh_token',
        value: 'refresh_token_123',
      )).called(1);
      
      verify(mockSecureStorage.write(
        key: 'user_data',
        value: anyNamed('value'),
      )).called(1);
    });

    test('should get saved user successfully', () async {
      // Arrange
      final userJson = '''
        {
          "id": "1",
          "username": "testuser",
          "email": "test@example.com",
          "firstName": "Test",
          "lastName": "User",
          "gender": "male",
          "image": "image_url"
        }
      ''';
      
      when(mockSecureStorage.read(key: 'user_data'))
          .thenAnswer((_) async => userJson);
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'access_token_123');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh_token_123');

      // Act
      final result = await authLocalDataSource.getUser();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.username, 'testuser');
      expect(result.token, 'access_token_123');
      expect(result.refreshToken, 'refresh_token_123');
    });

    test('should return null when user data is missing', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'user_data'))
          .thenAnswer((_) async => null);

      // Act
      final result = await authLocalDataSource.getUser();

      // Assert
      expect(result, isNull);
    });

    test('should return null when token is missing', () async {
      // Arrange
      final userJson = '{"id": "1", "username": "testuser"}';
      
      when(mockSecureStorage.read(key: 'user_data'))
          .thenAnswer((_) async => userJson);
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      // Act
      final result = await authLocalDataSource.getUser();

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthLocalDataSourceImpl - Clear Operations', () {
    test('should clear all stored data', () async {
      // Arrange
      when(mockSecureStorage.delete(any))
          .thenAnswer((_) async => Future.value());

      // Act
      await authLocalDataSource.clear();

      // Assert
      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
      verify(mockSecureStorage.delete(key: 'user_data')).called(1);
    });
  });

  group('AuthLocalDataSourceImpl - hasToken', () {
    test('should return true when token exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'valid_token');

      // Act
      final result = await authLocalDataSource.hasToken();

      // Assert
      expect(result, true);
    });

    test('should return false when token is null', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      // Act
      final result = await authLocalDataSource.hasToken();

      // Assert
      expect(result, false);
    });

    test('should return false when token is empty', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => '');

      // Act
      final result = await authLocalDataSource.hasToken();

      // Assert
      expect(result, false);
    });
  });
}