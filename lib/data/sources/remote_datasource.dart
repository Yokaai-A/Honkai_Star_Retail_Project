abstract class RemoteDataSource {
  Future<Map<String, dynamic>> googleLogin();
  Future<Map<String, dynamic>> login(String username, String password);
}
