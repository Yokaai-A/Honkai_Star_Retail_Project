import 'package:dart_either/dart_either.dart';
import 'package:honkai_star_retail_app/data/models/error_handling.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository.dart';

interface class AppLogin {
  final AuthRepository _authRepository;
  AppLogin(this._authRepository);

  Future<Either<Failure, Success>> execute(String email, String password) {
    return _authRepository.login(email, password);
  }
}
