part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {} // Triggers Splash Screen

class AuthLoading extends AuthState {} // Triggers UI Spinners

class AuthUnauthenticated extends AuthState {} // Triggers Login Screen

class AuthAuthenticated extends AuthState {
  final String token;
  final bool isAdmin;
  final String email;

  AuthAuthenticated({required this.token, required this.isAdmin, required this.email});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthRegisterSuccess extends AuthState {}
