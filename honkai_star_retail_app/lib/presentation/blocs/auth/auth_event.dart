part of 'auth_bloc.dart';

enum AuthLoginType { google, regular }

abstract class AuthEvent {}

class AuthInitializeEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final AuthLoginType loginType;
  final String email;
  final String password;

  AuthLoginEvent(this.email, this.password, this.loginType);
}

class AuthLogoutEvent extends AuthEvent {}

class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String password;

  AuthRegisterEvent(this.username, this.password);
}
