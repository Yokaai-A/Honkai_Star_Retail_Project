import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/core/services/api_service.dart';
import 'package:honkai_star_retail_app/domain/usecases/appGoogleLogin.dart';
import 'package:honkai_star_retail_app/domain/usecases/appLogin.dart';
import 'package:honkai_star_retail_app/domain/usecases/appRegister.dart';
// Assuming you have Failure/Success types accessible or imported
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppGoogleLogin _appGoogleLogin;
  final AppLogin _appLogin;
  final AppRegister _appRegister;

  AuthBloc({
    required AppGoogleLogin appGoogleLogin,
    required AppLogin appLogin,
    required AppRegister appRegister,
  })  : _appGoogleLogin = appGoogleLogin,
        _appLogin = appLogin,
        _appRegister = appRegister,
        super(AuthInitial()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthRegisterEvent>(_onRegister);
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Check for persisted token from ApiService (SharedPreferences)
    final token = await ApiService.instance.getToken();
    final role = await ApiService.instance.getRole();
    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(
        token: token,
        isAdmin: role == 'admin',
        email: '', // Username is tracked via ProfileController
      ));
    } else {
      emit(AuthUnauthenticated());
    }
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
            email: success.value['email'] ?? 'Trailblazer',
          ),
        );
      },
    );
  }

  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _appRegister.execute(event.username, event.password);

    result.fold(
      ifLeft: (failure) {
        emit(AuthError(failure.exception.toString()));
      },
      ifRight: (success) {
        emit(AuthRegisterSuccess());
        // Transition back to Unauthenticated so login works
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await ApiService.instance.clearToken();
    emit(AuthUnauthenticated());
  }
}
