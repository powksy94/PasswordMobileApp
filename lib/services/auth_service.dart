// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'crypto_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = "auth_token";
  static const _keyRole = "auth_role";
  static const _keyEmail = "auth_email";
  static final ApiService _api = ApiService();

  // clé dérivée en mémoire seulement
  static Uint8List? _masterKey;

  // --- Register: generate client salt, send it to server to store ---
  static Future<void> register(String email, String password, String masterPassword) async {
    // Génère un salt côté client pour la dérivation finale (16 bytes)
    final saltBytes = pcSecureRandom(16);
    final saltBase64 = base64Encode(saltBytes);

    // Appel server register (server stocke le salt pour login)
    await _api.register(email, password, saltBase64);

    // Derive key en mémoire
    final key = CryptoService.deriveKey(masterPassword, saltBase64);
    _masterKey = key;

    // Optionnel : stocker email pour UX
    await _storage.write(key: _keyEmail, value: email);
  }

  // --- Login: call server, receive salt, derive key in memory, save token ---
  static Future<void> login(String email, String password, String masterPassword) async {
    final res = await _api.login(email, password);
    final token = res['token'] as String;
    final role = res['role'] as String? ?? 'user';
    final saltBase64 = res['salt'] as String;

    // derive key in memory (do not persist key)
    final key = CryptoService.deriveKey(masterPassword, saltBase64);
    _masterKey = key;

    // store token + role + email in secure storage
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyEmail, value: email);
  }

  static Future<void> logout() async {
    _masterKey = null;
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyEmail);
  }

  static Future<bool> isLoggedIn() async {
    final t = await _storage.read(key: _keyToken);
    return t != null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  static Uint8List? getMasterKey() => _masterKey;

  // Returns the stored backend role string ('admin', 'team_admin', or 'user')
  static Future<String> getUserRoleString() async {
    return await _storage.read(key: _keyRole) ?? 'user';
  }

  // Updates token and role in secure storage after a bootstrap/role-change call
  static Future<void> updateTokenAndRole(String newToken, String role) async {
    await _storage.write(key: _keyToken, value: newToken);
    await _storage.write(key: _keyRole, value: role);
  }

  // Utility: generate cryptographically secure random bytes
  static Uint8List pcSecureRandom(int length) {
    final rnd = Random.secure();
    final out = Uint8List(length);
    for (int i = 0; i < length; i++) {
      out[i] = rnd.nextInt(256);
    }
    return out;
  }
}
