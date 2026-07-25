import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_service.dart';
import './master_key_service.dart';
import './biometric_unlock_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyRole  = 'auth_role';
  static const _keyEmail = 'auth_email';

  static const _prefLoggedOut = 'session_logged_out';
  static const _prefUserEmail = 'user_email';
  static const _prefUserId    = 'user_id';

  static final ApiService _api = ApiService();

  // ── Register ──────────────────────────────────────────────────────────────────

  static Future<void> register(
      String email, String password, String masterPassword) async {
    final saltBase64 = base64Encode(MasterKeyService.pcSecureRandom(16));
    await _api.register(email, password, saltBase64);
    await _storage.write(key: _keyEmail, value: email);
    await MasterKeyService.setupFromLogin(saltBase64, masterPassword);
  }

  // ── Login ─────────────────────────────────────────────────────────────────────

  static Future<({String token, String role, String salt})> loginToServer(
      String email, String password) async {
    final res = await _api.login(email, password);
    return (
      token: res['token'] as String,
      role:  res['role']  as String? ?? 'user',
      salt:  res['salt']  as String,
    );
  }

  static Future<void> completeLogin({
    required String token,
    required String role,
    required String salt,
    required String masterPassword,
    required String email,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole,  value: role);
    await _storage.write(key: _keyEmail, value: email);
    await MasterKeyService.setupFromLogin(salt, masterPassword);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLoggedOut);
    await prefs.setString(_prefUserEmail, email);
    final userId = _extractUserIdFromToken(token);
    if (userId != null) await prefs.setString(_prefUserId, userId);
  }

  static Future<void> login(
      String email, String password, String masterPassword) async {
    final s = await loginToServer(email, password);
    await completeLogin(
      token: s.token, role: s.role, salt: s.salt,
      masterPassword: masterPassword, email: email,
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    MasterKeyService.clearMasterKey();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLoggedOut, true);
  }

  static Future<void> fullLogout() async {
    MasterKeyService.clearMasterKey();
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyEmail);
    await MasterKeyService.deleteAll();
    await BiometricUnlockService.disable();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLoggedOut);
    await prefs.remove(_prefUserEmail);
    await prefs.remove(_prefUserId);
  }

  // ── Session ───────────────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefLoggedOut) ?? false);
  }

  static Future<bool> hasLoggedOutSession() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefLoggedOut) ?? false;
  }

  static Future<bool> restoreSessionAfterBiometric({
    required String promptTitle,
    required String cancelLabel,
  }) async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return false;
    final key = await BiometricUnlockService.unlock(
      promptTitle: promptTitle,
      cancelLabel: cancelLabel,
    );
    if (key == null) return false;
    MasterKeyService.setUnlockedKey(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLoggedOut);
    return true;
  }

  // ── Getters ───────────────────────────────────────────────────────────────────

  static Future<String?> getToken() => _storage.read(key: _keyToken);
  static Future<String?> getRole()  => _storage.read(key: _keyRole);

  static Future<String?> getEmail() async {
    try {
      final v = await _storage.read(key: _keyEmail);
      if (v != null) return v;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefUserEmail);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefUserId);
  }

  static Future<String> getUserRoleString() async =>
      await _storage.read(key: _keyRole) ?? 'user';

  static Future<void> updateTokenAndRole(String newToken, String role) async {
    await _storage.write(key: _keyToken, value: newToken);
    await _storage.write(key: _keyRole,  value: role);
  }

  // ── Privé ─────────────────────────────────────────────────────────────────────

  static String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      return payload['id'] as String?;
    } catch (_) {
      return null;
    }
  }
}
