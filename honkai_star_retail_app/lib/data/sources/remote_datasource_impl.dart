import 'package:honkai_star_retail_app/core/services/api_service.dart';
import 'package:honkai_star_retail_app/data/sources/remote_datasource.dart';

class RemoteDataSourceImplementation implements RemoteDataSource {
  final ApiService _apiService;

  RemoteDataSourceImplementation({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> googleLogin() async {
    // Google Sign-In tidak di-support untuk integrasi REST API server ini.
    throw Exception(
      'Google Sign-In tidak tersedia. Gunakan username & password.',
    );
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Call REST API server: POST /api/auth/login
    final result = await _apiService.login(username, password);
    return {
      'uid': result['username'],
      'email': result['username'],
      'role': result['role'],
      'token': result['token'],
    };
  }

  @override
  Future<void> register(String username, String password) async {
    // Call REST API server: POST /api/auth/register
    await _apiService.register(username, password);
  }
}
