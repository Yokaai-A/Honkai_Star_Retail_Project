import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/domain/usecases/appGoogleLogin.dart';
import 'package:honkai_star_retail_app/domain/usecases/appLogin.dart';
// Assuming you have Failure/Success types accessible or imported
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppGoogleLogin _appGoogleLogin;
  final AppLogin _appLogin;

  AuthBloc({required AppGoogleLogin appGoogleLogin, required AppLogin appLogin})
    : _appGoogleLogin = appGoogleLogin,
      _appLogin = appLogin,
      super(AuthInitial()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Await actual secure storage check
    await Future.delayed(const Duration(seconds: 2));
    emit(AuthUnauthenticated());
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // Execute the appropriate use case based on event type
    final result = await (event.loginType == AuthLoginType.google
        ? _appGoogleLogin.execute()
        : _appLogin.execute(event.email, event.password));

    // Resolve the Either type directly. No try/catch needed unless the
    // use case itself throws unhandled fatal exceptions.
    result.fold(
      ifLeft: (failure) {
        emit(AuthError(failure.exception.toString()));
      },
      ifRight: (success) {
        emit(
          AuthAuthenticated(
            token: success.value['token'],
            isAdmin: success.value['role'] == 'admin',
          ),
        );
      },
    );
  }

  void _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) {
    // TODO: Await secure storage clearance
    emit(AuthUnauthenticated());
  }
}
