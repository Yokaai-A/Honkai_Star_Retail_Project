import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource.dart';
import 'package:mysql_client/mysql_client.dart';

class RemoteDataSourceImplementation implements RemoteDataSource {
  final MySQLConnectionPool _mySQLConnectionPool;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  RemoteDataSourceImplementation({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required MySQLConnectionPool mySQLConnectionPool,
  }) : _mySQLConnectionPool = mySQLConnectionPool,
       _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  @override
  Future<Map<String, dynamic>> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        throw Exception('Google Sign-In aborted by the user.');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase authentication returned a null user.');
      }
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during Google Login: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // 1. Authenticate with Firebase first (assuming standard email/password)
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase authentication returned a null user.');
      }

      final IResultSet result = await _mySQLConnectionPool.execute(
        "SELECT * FROM users WHERE firebase_uid = :uid LIMIT 1",
        {"uid": user.uid},
      );

      if (result.rows.isEmpty) {
        throw Exception(
          'User authenticated in Firebase but not found in MySQL database.',
        );
      }

      final userRow = result.rows.first;

      return {
        'uid': user.uid,
        'email': user.email,
        'retail_role': userRow.colByName('role'),
        'token': await user.getIdToken(),
      };
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during login: $e');
    }
  }
}
