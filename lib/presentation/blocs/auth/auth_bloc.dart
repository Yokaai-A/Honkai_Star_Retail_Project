import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Check secure storage for existing token here
    await Future.delayed(const Duration(seconds: 2));

    // Defaulting to unauthenticated for the assignment flow
    emit(AuthUnauthenticated());
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 2. Execute Node.js API call here
      await Future.delayed(const Duration(seconds: 2));

      // 3. Mock Authentication Logic
      final String inputUser = event.username.trim().toLowerCase();
      final bool isAdmin = inputUser == 'admin';
      const String mockBearerToken = 'n8x7wfqtsrvxnvsm8dcz';

      emit(AuthAuthenticated(token: mockBearerToken, isAdmin: isAdmin));
    } catch (e) {
      emit(AuthError("System Error: Authentication Failed"));
      emit(
        AuthUnauthenticated(),
      ); // Revert to unauthenticated so user can try again
    }
  }

  void _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) {
    // 4. Clear secure storage here
    emit(AuthUnauthenticated());
  }
}
