import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource_impl.dart';
import 'package:mysql_client/mysql_client.dart';

GetIt di = GetIt.instance;

void injectDependency() {
  // Singleton
  di.registerLazySingleton<RemoteDataSourceImplementation>(
    () => RemoteDataSourceImplementation(
      firebaseAuth: di<FirebaseAuth>(),
      googleSignIn: di<GoogleSignIn>(),
      mySQLConnectionPool: di<MySQLConnectionPool>(),
    ),
  );

  // Factory (State Management, etc.)
}
