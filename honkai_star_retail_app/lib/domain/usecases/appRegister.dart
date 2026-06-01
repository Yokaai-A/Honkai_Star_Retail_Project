import 'package:dart_either/dart_either.dart';
import 'package:honkai_star_retail_app/data/models/error_handling.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository.dart';

interface class AppRegister {
  final AuthRepository _authRepository;
  AppRegister(this._authRepository);

  Future<Either<Failure, Success>> execute(String username, String password) {
    return _authRepository.register(username, password);
  }
}
