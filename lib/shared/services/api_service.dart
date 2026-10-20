import 'package:dio/dio.dart';
import './session_expiry_interceptor.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://passwordmobileappbackend-production.up.railway.app'))
    ..interceptors.add(SessionExpiryInterceptor());

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

  /// Rotates the refresh token: returns a new `token`/`refreshToken`/`role`.
  /// A dead session answers 401 with code `REFRESH_INVALID`.
  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    final res = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  /// Emails a one-time code if the account exists. Always succeeds (202)
  /// for any email: the server never tells which accounts exist.
  Future<void> requestPasswordReset(String email) async {
    await _dio.post('/auth/password-reset/request', data: {'email': email});
  }

  /// Sets [newPassword] if [code] is valid. A rejection answers 400 with
  /// code `INVALID_CODE` or `WEAK_PASSWORD`.
  Future<void> confirmPasswordReset(String email, String code, String newPassword) async {
    await _dio.post('/auth/password-reset/confirm', data: {
      'email':       email,
      'code':        code,
      'newPassword': newPassword,
    });
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

  Future<void> updateItem(String token, String id, Map<String, dynamic> payload) async {
    await _dio.put('/vault/$id',
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Replaces, in a single all-or-nothing transaction, the encrypted content of all
  /// the listed items (master password change). [items] must contain,
  /// for each entry, at least `id`, `title` and `password` already encrypted
  /// with the new key.
  Future<void> reencryptVault(String token, List<Map<String, dynamic>> items) async {
    await _dio.put('/vault/reencrypt-all',
      data: {'items': items},
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

  /// Other devices are logged out: the response carries this device's new
  /// session (`token`/`refreshToken`/`role`).
  Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    final res = await _dio.post(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> registerFcmToken(String token, String fcmToken, {String? locale}) async {
    await _dio.post(
      '/auth/fcm-token',
      data: {'fcmToken': fcmToken, if (locale != null) 'locale': locale},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Map<String, dynamic>> getWeakReminderSettings(String token) async {
    final response = await _dio.get(
      '/auth/weak-reminder-settings',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateWeakReminderSettings(
    String token, {
    required bool enabled,
    required bool includeMedium,
    required List<int> delaysHours,
  }) async {
    await _dio.put(
      '/auth/weak-reminder-settings',
      data: {
        'enabled': enabled,
        'includeMedium': includeMedium,
        'delaysHours': delaysHours,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> respondAdminSession(
      String token, String sessionId, bool approved) async {
    await _dio.post(
      '/admin-auth/respond',
      data: {'sessionId': sessionId, 'approved': approved},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> respondVaultAuth(
      String token, String sessionId, bool approved) async {
    await _dio.post(
      '/admin/vault/auth/respond',
      data: {'sessionId': sessionId, 'approved': approved},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> purgeVault(String token) async {
    await _dio.delete(
      '/vault/all',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> deleteAccount(String token) async {
    await _dio.delete(
      '/auth/account',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}