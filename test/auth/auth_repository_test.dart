import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
 

@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource])
void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepositoryImpl authRepository;

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
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('AuthRepositoryImpl - login', () {
    test('should call remote login and save user locally', () async {
      // Arrange
      final username = 'testuser';
      final password = 'password123';
      
      when(mockRemoteDataSource.login(username, password))
          .thenAnswer((_) async => mockUser);
      when(mockLocalDataSource.saveUser(mockUser))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await authRepository.login(username, password);

      // Assert
      expect(result, mockUser);
      verify(mockRemoteDataSource.login(username, password)).called(1);
      verify(mockLocalDataSource.saveUser(mockUser)).called(1);
    });

    test('should propagate remote login errors', () async {
      // Arrange
      final username = 'testuser';
      final password = 'wrongpassword';
      final errorMessage = 'Invalid credentials';
      
      when(mockRemoteDataSource.login(username, password))
          .thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => authRepository.login(username, password),
        throwsA(isA<Exception>()),
      );
      verifyNever(mockLocalDataSource.saveUser(any));
    });
  });

  group('AuthRepositoryImpl - logout', () {
    test('should clear local storage on logout', () async {
      // Arrange
      when(mockLocalDataSource.clear())
          .thenAnswer((_) async => Future.value());

      // Act
      await authRepository.logout();

      // Assert
      verify(mockLocalDataSource.clear()).called(1);
    });

    test('should handle logout errors gracefully', () async {
      // Arrange
      when(mockLocalDataSource.clear())
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => authRepository.logout(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepositoryImpl - getCurrentUser', () {
    test('should return user from local storage', () async {
      // Arrange
      when(mockLocalDataSource.getUser())
          .thenAnswer((_) async => mockUser);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, mockUser);
      verify(mockLocalDataSource.getUser()).called(1);
    });

    test('should return null when no user in local storage', () async {
      // Arrange
      when(mockLocalDataSource.getUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthRepositoryImpl - validateSession', () {
    test('should validate session with remote server', () async {
      // Arrange
      final token = 'valid_token';
      final validatedUser = mockUser.copyWith(token: token);
      
      when(mockRemoteDataSource.getCurrentUser(token))
          .thenAnswer((_) async => validatedUser);

      // Act
      final result = await authRepository.validateSession(token);

      // Assert
      expect(result, validatedUser);
      verify(mockRemoteDataSource.getCurrentUser(token)).called(1);
    });

    test('should throw error on invalid session', () async {
      // Arrange
      final token = 'invalid_token';
      
      when(mockRemoteDataSource.getCurrentUser(token))
          .thenThrow(Exception('Invalid token'));

      // Act & Assert
      expect(
        () => authRepository.validateSession(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepositoryImpl - saveUser', () {
    test('should save user to local storage', () async {
      // Arrange
      when(mockLocalDataSource.saveUser(mockUser))
          .thenAnswer((_) async => Future.value());

      // Act
      await authRepository.saveUser(mockUser);

      // Assert
      verify(mockLocalDataSource.saveUser(mockUser)).called(1);
    });
  });

  group('AuthRepositoryImpl - hasToken', () {
    test('should return true when token exists', () async {
      // Arrange
      when(mockLocalDataSource.hasToken())
          .thenAnswer((_) async => true);

      // Act
      final result = await authRepository.hasToken();

      // Assert
      expect(result, true);
    });

    test('should return false when no token exists', () async {
      // Arrange
      when(mockLocalDataSource.hasToken())
          .thenAnswer((_) async => false);

      // Act
      final result = await authRepository.hasToken();

      // Assert
      expect(result, false);
    });
  });
}