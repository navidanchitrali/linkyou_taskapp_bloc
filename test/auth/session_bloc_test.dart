import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:linkyou_tasks_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:linkyou_tasks_app/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
 

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late SessionBloc sessionBloc;

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
    mockAuthRepository = MockAuthRepository();
    sessionBloc = SessionBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    sessionBloc.close();
  });

  group('SessionBloc - CheckSession', () {
    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionAuthenticated] when token exists and user is valid',
      build: () {
        when(mockAuthRepository.hasToken()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
        return sessionBloc;
      },
      act: (bloc) => bloc.add(CheckSession()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionAuthenticated>()
          .having((state) => state.user.id, 'user id', '1')
          .having((state) => state.user.token, 'user token', 'access_token_123'),
      ],
      verify: (_) {
        verify(mockAuthRepository.hasToken()).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionUnauthenticated] when no token exists',
      build: () {
        when(mockAuthRepository.hasToken()).thenAnswer((_) async => false);
        return sessionBloc;
      },
      act: (bloc) => bloc.add(CheckSession()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.hasToken()).called(1);
        verifyNever(mockAuthRepository.getCurrentUser());
      },
    );

    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionUnauthenticated] when token exists but user retrieval fails',
      build: () {
        when(mockAuthRepository.hasToken()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
        return sessionBloc;
      },
      act: (bloc) => bloc.add(CheckSession()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionUnauthenticated] when repository throws exception',
      build: () {
        when(mockAuthRepository.hasToken()).thenThrow(Exception('Storage error'));
        return sessionBloc;
      },
      act: (bloc) => bloc.add(CheckSession()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
      ],
    });
  });

  group('SessionBloc - LoginRequested', () {
    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionAuthenticated] on successful login',
      build: () {
        final username = 'testuser';
        final password = 'password123';
        
        when(mockAuthRepository.login(username, password))
            .thenAnswer((_) async => mockUser);
        return sessionBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        username: 'testuser',
        password: 'password123',
      )),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionAuthenticated>()
          .having((state) => state.user.username, 'username', 'testuser'),
      ],
      verify: (_) {
        verify(mockAuthRepository.login('testuser', 'password123')).called(1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionError] on login failure',
      build: () {
        final username = 'testuser';
        final password = 'wrongpassword';
        
        when(mockAuthRepository.login(username, password))
            .thenThrow(Exception('Invalid credentials'));
        return sessionBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        username: 'testuser',
        password: 'wrongpassword',
      )),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionError>()
          .having((state) => state.message, 'error message', contains('Login failed')),
      ],
    );
  });

  group('SessionBloc - LogoutRequested', () {
    blocTest<SessionBloc, SessionState>(
      'should emit [SessionLoading, SessionUnauthenticated] on successful logout',
      build: () {
        when(mockAuthRepository.logout()).thenAnswer((_) async => Future.value());
        return sessionBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.logout()).called(1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'should still emit SessionUnauthenticated even if logout fails',
      build: () {
        when(mockAuthRepository.logout()).thenThrow(Exception('Logout failed'));
        return sessionBloc;
      },
      seed: () => SessionAuthenticated(user: mockUser),
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
      ],
    );
  });

  group('SessionBloc - Edge Cases', () {
    blocTest<SessionBloc, SessionState>(
      'should handle multiple consecutive events correctly',
      build: () {
        when(mockAuthRepository.hasToken()).thenAnswer((_) async => false);
        return sessionBloc;
      },
      act: (bloc) {
        bloc.add(CheckSession());
        bloc.add(CheckSession());
        bloc.add(LogoutRequested());
      },
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
        isA<SessionLoading>(),
        isA<SessionUnauthenticated>(),
      ],
    );

    test('initial state should be SessionInitial', () {
      expect(sessionBloc.state, isA<SessionInitial>());
    });
  });
}