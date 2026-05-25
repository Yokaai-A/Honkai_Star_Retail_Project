import 'package:flutter/foundation.dart';

/// The abstract interface required by the router
abstract class AuthManager extends ChangeNotifier {
  bool get isInitializing;
  bool get isLoggedIn;
  bool get isAdmin;
  String? get token; // 1. Interface definition added
}

/// The concrete implementation
class AuthManagerImpl extends ChangeNotifier implements AuthManager {
  bool _isInitializing = true;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String? _token;

  @override
  bool get isInitializing => _isInitializing;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  bool get isAdmin => _isAdmin;

  @override
  String? get token => _token;

  // Inside AuthManagerImpl
  Future<void> initializeApp() async {
    try {
      // Your actual storage reads go here
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (kDebugMode) {
        print('CRITICAL INIT ERROR: $e');
      } // Catch silent crashes
    } finally {
      // This MUST execute no matter what
      _isInitializing = false;
      notifyListeners();
    }
  }

  void login(String newToken, String role) {
    _token = newToken;
    _isLoggedIn = true;
    _isAdmin = role == 'admin';

    // 6. Persistence requirement:
    // unawaited(secureStorage.write(key: 'bearer_token', value: newToken));

    notifyListeners();
  }

  void logout() {
    _token = null;
    _isLoggedIn = false;
    _isAdmin = false;

    // 7. Cleanup requirement:
    // unawaited(secureStorage.delete(key: 'bearer_token'));

    notifyListeners();
  }
}
