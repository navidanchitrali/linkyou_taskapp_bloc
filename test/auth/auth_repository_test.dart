import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:linkyou_tasks_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:linkyou_tasks_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:linkyou_tasks_app/features/auth/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

 

// Mocks
class MockDio extends Mock implements Dio {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('AuthRepository', () {
    const testUsername = 'testuser';
    const testPassword = 'testpass';
    final testUser = User(
      id: '1',
      username: 'testuser',
      email: 'test@test.com',
      firstName: 'Test',
      lastName: 'User',
      gender: 'male',
      image: '',
      token: 'test_token',
    );

    test('login should return user on successful authentication', () async {
      // Arrange
      when(mockRemoteDataSource.login(testUsername, testPassword))
          .thenAnswer((_) async => testUser);
      when(mockLocalDataSource.saveUser(testUser))
          .thenAnswer((_) async => null);

      // Act
      final result = await authRepository.login(testUsername, testPassword);

      // Assert
      expect(result, equals(testUser));
      verify(mockRemoteDataSource.login(testUsername, testPassword)).called(1);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
    });

    test('getCurrentUser should return user when stored', () async {
      // Arrange
      when(mockLocalDataSource.getUser()).thenAnswer((_) async => testUser);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, equals(testUser));
      verify(mockLocalDataSource.getUser()).called(1);
    });

    test('getCurrentUser should return null when no user stored', () async {
      // Arrange
      when(mockLocalDataSource.getUser()).thenAnswer((_) async => null);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(mockLocalDataSource.getUser()).called(1);
    });

    test('logout should clear local storage', () async {
      // Arrange
      when(mockLocalDataSource.clear()).thenAnswer((_) async => null);

      // Act
      await authRepository.logout();

      // Assert
      verify(mockLocalDataSource.clear()).called(1);
    });
  });
}