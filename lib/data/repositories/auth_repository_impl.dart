import 'package:dart_either/dart_either.dart';
import 'package:honkai_star_retail_app/data/models/error_handling.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  AuthRepositoryImpl({required RemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Success>> googleLogin() async {
    try {
      final response = await _remoteDataSource.googleLogin();
      return Right(Success(response));
    } catch (e) {
      return Left(Failure(Exception(e)));
    }
  }

  @override
  Future<Either<Failure, Success>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _remoteDataSource.login(username, password);
      return Right(Success(response));
    } catch (e) {
      return Left(Failure(Exception(e)));
    }
  }
}
