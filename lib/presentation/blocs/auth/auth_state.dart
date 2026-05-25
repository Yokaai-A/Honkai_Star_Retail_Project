part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {} // Triggers Splash Screen

class AuthLoading extends AuthState {} // Triggers UI Spinners

class AuthUnauthenticated extends AuthState {} // Triggers Login Screen

class AuthAuthenticated extends AuthState {
  final String token;
  final bool isAdmin;

  AuthAuthenticated({required this.token, required this.isAdmin});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
