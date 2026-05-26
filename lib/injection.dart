import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:honkai_star_retail_app/app_router.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository_impl.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource_impl.dart';
import 'package:honkai_star_retail_app/domain/usecases/appGoogleLogin.dart';
import 'package:honkai_star_retail_app/domain/usecases/appLogin.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:mysql_client/mysql_client.dart';

GetIt di = GetIt.instance;

void injectDependency() {
  // Singleton (Repositories, RemoteDataSource, etc. )
  di.registerLazySingleton<RemoteDataSourceImplementation>(
    () => RemoteDataSourceImplementation(
      firebaseAuth: di<FirebaseAuth>(),
      googleSignIn: di<GoogleSignIn>(),
      mySQLConnectionPool: di<MySQLConnectionPool>(),
    ),
  );

  di.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
  );

  // Usecases
  di.registerSingleton(AppGoogleLogin(di<AuthRepository>()));
  di.registerSingleton(AppLogin(di<AuthRepository>()));

  // Factory (State Management, etc.)
  di.registerFactory(
    () => AuthBloc(
      appGoogleLogin: di<AppGoogleLogin>(),
      appLogin: di<AppLogin>(),
    ),
  );

  // App Router
  di.registerLazySingleton<AppRouter>(() => AppRouter(di<AuthBloc>()));
}
