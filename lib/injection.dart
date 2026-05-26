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

// Use GetIt.instance to ensure you are hitting the global locator,
// rather than scoping a new isolated instance unless explicitly required by your architecture.
GetIt di = GetIt.instance;

Future<void> injectDependency() async {
  // 1. External Dependencies & Core Services
  di.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  di.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // 2. Initialize and Register MySQL Pool
  di.registerSingleton<MySQLConnectionPool>(await initializeMySQLPool());

  // 2. Data Sources
  di.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImplementation(
      firebaseAuth: di<FirebaseAuth>(),
      googleSignIn: di<GoogleSignIn>(),
      mySQLConnectionPool: di<MySQLConnectionPool>(),
    ),
  );

  // 3. Repositories
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
  );

  // 4. Use Cases (Converted to LazySingleton to prevent startup lag and order-of-execution crashes)
  di.registerLazySingleton<AppGoogleLogin>(
    () => AppGoogleLogin(di<AuthRepository>()),
  );
  di.registerLazySingleton<AppLogin>(() => AppLogin(di<AuthRepository>()));

  // 5. State Management (Must be LazySingleton if injected into a Singleton Router)
  di.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      appGoogleLogin: di<AppGoogleLogin>(),
      appLogin: di<AppLogin>(),
    ),
  );

  // 6. Router (Depends on global AuthBloc state)
  di.registerLazySingleton<AppRouter>(() => AppRouter(di<AuthBloc>()));
}

Future<MySQLConnectionPool> initializeMySQLPool() async {
  try {
    return MySQLConnectionPool(
      host: '127.0.0.1', // Replace with your DB host
      port: 3306,
      userName: 'root', // Replace with your DB user
      password: 'password', // Replace with your DB password
      databaseName: 'honkai_retail', // Replace with your DB name
      maxConnections: 10,
    );
  } catch (e) {
    throw Exception('CRITICAL: Database failed to connect on startup. $e');
  }
}
