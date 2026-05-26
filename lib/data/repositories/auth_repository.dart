import 'package:dart_either/dart_either.dart';
import 'package:honkai_star_retail_app/data/models/error_handling.dart';

abstract class AuthRepository {
  Future<Either<Failure, Success>> googleLogin();
  Future<Either<Failure, Success>> login(String username, String password);
}
