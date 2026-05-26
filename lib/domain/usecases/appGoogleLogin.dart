import 'package:dart_either/dart_either.dart';
import 'package:honkai_star_retail_app/data/models/error_handling.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository.dart';

interface class AppGoogleLogin {
  final AuthRepository _authRepository;
  AppGoogleLogin(this._authRepository);

  Future<Either<Failure, Success>> execute() {
    return _authRepository.googleLogin();
  }
}
