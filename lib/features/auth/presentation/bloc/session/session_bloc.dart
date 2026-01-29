import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:linkyou_tasks_app/features/auth/domain/entities/user.dart';
import 'package:linkyou_tasks_app/features/auth/domain/repositories/auth_repository.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthRepository authRepository;

  SessionBloc({required this.authRepository}) : super(SessionInitial()) {
    on<CheckSession>(_onCheckSession);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckSession(
    CheckSession event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    
    try {
      final hasToken = await authRepository.hasToken();
      
      if (!hasToken) {
        emit(SessionUnauthenticated());
        return;
      }
      
      final user = await authRepository.getCurrentUser();
      
      if (user != null && user.token.isNotEmpty) {
        emit(SessionAuthenticated(user: user));
      } else {
        emit(SessionUnauthenticated());
      }
    } catch (e) {
      emit(SessionUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final user = await authRepository.login(
        event.username,
        event.password,
      );
      emit(SessionAuthenticated(user: user));
    } catch (e) {
      emit(SessionError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      await authRepository.logout();
      emit(SessionUnauthenticated());
    } catch (e) {
      emit(SessionUnauthenticated());
    }
  }
}