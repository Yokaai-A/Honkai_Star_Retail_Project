part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthInitializeEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  AuthLoginEvent(this.username, this.password);
}

class AuthLogoutEvent extends AuthEvent {}
