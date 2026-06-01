import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service untuk semua HTTP call ke REST API server.
/// Base URL: http://localhost:3000
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  static const String _baseUrl = 'http://localhost:3000';
  static const String _tokenKey = 'hsr_api_token';
  static const String _roleKey = 'hsr_api_role';

  // ─── Token Management ────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Login via POST /api/auth/login
  /// Returns map: { token, role } on success.
  /// Throws Exception on failure.
  Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = body['token'] as String;
        final role = body['role'] as String? ?? 'user';
        await saveToken(token, role);
        return {'token': token, 'role': role, 'username': username};
      } else {
        throw Exception(body['message'] ?? 'Login gagal');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Register via POST /api/auth/register
  /// Throws Exception on failure.
  Future<void> register(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/api/auth/register');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'role': 'user',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(body['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  // ─── Resources / Catalog ──────────────────────────────────────────────────

  /// GET /api/resources – ambil semua resource dari DB
  Future<List<Map<String, dynamic>>> getResources() async {
    final uri = Uri.parse('$_baseUrl/api/resources');
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal mengambil data catalog');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  /// GET /api/resources/:id – detail satu resource
  Future<Map<String, dynamic>> getResourceById(dynamic id) async {
    final uri = Uri.parse('$_baseUrl/api/resources/$id');
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Resource tidak ditemukan');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  /// GET /api/stats – statistik untuk admin dashboard (total users, resources, transactions)
  Future<Map<String, dynamic>> getStats() async {
    final uri = Uri.parse('$_baseUrl/api/stats');
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Gagal mengambil statistik');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  /// POST /api/resources – tambah resource baru (Admin only, pakai Bearer token)
  Future<void> createResource(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse('$_baseUrl/api/resources');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(body['message'] ?? 'Gagal menambah resource');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Cek apakah server dapat dijangkau
  Future<bool> isServerReachable() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Debug helper ─────────────────────────────────────────────────────────
  void log(String msg) {
    if (kDebugMode) debugPrint('[ApiService] $msg');
  }
}
