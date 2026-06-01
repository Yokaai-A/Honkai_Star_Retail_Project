abstract class RemoteDataSource {
  Future<Map<String, dynamic>> googleLogin();
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> register(String email, String password);
}
