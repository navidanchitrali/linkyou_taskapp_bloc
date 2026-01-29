part of 'session_bloc.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionAuthenticated extends SessionState {
  final User user;

  const SessionAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class SessionUnauthenticated extends SessionState {}

class SessionError extends SessionState {
  final String message;

  const SessionError({required this.message});

  @override
  List<Object> get props => [message];
}