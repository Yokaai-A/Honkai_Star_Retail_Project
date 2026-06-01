import 'package:get_it/get_it.dart';
import 'package:honkai_star_retail_app/app_router.dart';
import 'package:honkai_star_retail_app/core/services/api_service.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository.dart';
import 'package:honkai_star_retail_app/data/repositories/auth_repository_impl.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource_impl.dart';
import 'package:honkai_star_retail_app/domain/usecases/appGoogleLogin.dart';
import 'package:honkai_star_retail_app/domain/usecases/appLogin.dart';
import 'package:honkai_star_retail_app/domain/usecases/appRegister.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';

GetIt di = GetIt.instance;

Future<void> injectDependency() async {
  // 1. Core Services
  di.registerLazySingleton<ApiService>(() => ApiService.instance);

  // 2. Data Sources
  di.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImplementation(apiService: di<ApiService>()),
  );

  // 3. Repositories
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: di<RemoteDataSource>()),
  );

  // 4. Use Cases
  di.registerLazySingleton<AppGoogleLogin>(
    () => AppGoogleLogin(di<AuthRepository>()),
  );
  di.registerLazySingleton<AppLogin>(() => AppLogin(di<AuthRepository>()));
  di.registerLazySingleton<AppRegister>(
    () => AppRegister(di<AuthRepository>()),
  );

  // 5. State Management
  di.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      appGoogleLogin: di<AppGoogleLogin>(),
      appLogin: di<AppLogin>(),
      appRegister: di<AppRegister>(),
    ),
  );

  // 6. Router
  di.registerLazySingleton<AppRouter>(() => AppRouter(di<AuthBloc>()));
}
