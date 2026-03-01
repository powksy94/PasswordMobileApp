import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://passwordmobileappbackend-production.up.railway.app'));

  Future<void> register(String email, String password, String salt) async {
    await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'salt': salt,
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getVault(String token) async {
    final res = await _dio.get('/vault', options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data as List<dynamic>;
  }

  Future<void> addItem(String token, Map<String, dynamic> payload) async {
    await _dio.post('/vault',
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> deleteItem(String token, String id) async {
    await _dio.delete('/vault/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<dynamic>> getAllUsers(String token) async {
    final res = await _dio.get(
      '/admin/users',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data as List<dynamic>;
  }

  Future<void> updateUserRole(String token, String userId, String role) async {
    await _dio.post(
      '/admin/role',
      data: {'userId': userId, 'role': role},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}