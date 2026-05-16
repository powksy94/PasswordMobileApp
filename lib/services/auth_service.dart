// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'crypto_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken        = 'auth_token';
  static const _keyRole         = 'auth_role';
  static const _keyEmail        = 'auth_email';
  static const _keySalt         = 'auth_salt';
  static const _keyVerification = 'key_verification';
  static const _keyMasterKey    = 'master_key_b64';

  // Texte connu chiffré avec la master key pour vérification locale
  static const _verificationText = 'VAULT_VERIFY_v1';

  static final ApiService _api = ApiService();

  // Clé dérivée en mémoire seulement
  static Uint8List? _masterKey;

  // ── Register ────────────────────────────────────────────────────────────────

  static Future<void> register(
    String email,
    String password,
    String masterPassword,
  ) async {
    final saltBytes = pcSecureRandom(16);
    final saltBase64 = base64Encode(saltBytes);

    await _api.register(email, password, saltBase64);

    final key = CryptoService.deriveKey(masterPassword, saltBase64);
    _masterKey = key;

    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keySalt,  value: saltBase64);
    await _persistKeyArtifacts(key);
  }

  // ── Login ────────────────────────────────────────────────────────────────────

  static Future<void> login(
    String email,
    String password,
    String masterPassword,
  ) async {
    final res = await _api.login(email, password);
    final token      = res['token'] as String;
    final role       = res['role']  as String? ?? 'user';
    final saltBase64 = res['salt']  as String;

    final key = CryptoService.deriveKey(masterPassword, saltBase64);
    _masterKey = key;

    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole,  value: role);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keySalt,  value: saltBase64);
    await _persistKeyArtifacts(key);
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    _masterKey = null;
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keySalt);
    await _storage.delete(key: _keyVerification);
    await _storage.delete(key: _keyMasterKey);
  }

  // ── Auto-lock ────────────────────────────────────────────────────────────────

  /// Efface la clé de la mémoire (vault verrouillé). Ne déconnecte pas l'utilisateur.
  static void clearMasterKey() => _masterKey = null;

  /// Déverrouille avec le mot de passe maître. Retourne true si correct.
  static Future<bool> unlockWithMasterPassword(String masterPassword) async {
    final saltBase64 = await _storage.read(key: _keySalt);
    if (saltBase64 == null) return false;

    final key = CryptoService.deriveKey(masterPassword, saltBase64);

    final token = await _storage.read(key: _keyVerification);
    if (token == null) {
      // Pas de token de vérification (compte ancien) → accepte et persiste
      _masterKey = key;
      await _persistKeyArtifacts(key);
      return true;
    }

    try {
      final decrypted = CryptoService.decryptText(token, key);
      if (decrypted != _verificationText) return false;
      _masterKey = key;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Déverrouille depuis le stockage sécurisé (utilisé après auth biométrique).
  static Future<bool> unlockFromStorage() async {
    final stored = await _storage.read(key: _keyMasterKey);
    if (stored == null) return false;
    _masterKey = Uint8List.fromList(base64Decode(stored));
    return true;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async =>
      (await _storage.read(key: _keyToken)) != null;

  static Future<String?> getToken() => _storage.read(key: _keyToken);

  static Future<String?> getRole() => _storage.read(key: _keyRole);

  static Uint8List? getMasterKey() => _masterKey;

  static Future<String> getUserRoleString() async =>
      await _storage.read(key: _keyRole) ?? 'user';

  static Future<void> updateTokenAndRole(String newToken, String role) async {
    await _storage.write(key: _keyToken, value: newToken);
    await _storage.write(key: _keyRole,  value: role);
  }

  static Uint8List pcSecureRandom(int length) {
    final rnd = Random.secure();
    final out = Uint8List(length);
    for (int i = 0; i < length; i++) { out[i] = rnd.nextInt(256); }
    return out;
  }

  // Stocke le token de vérification + la clé pour déverrouillage biométrique
  static Future<void> _persistKeyArtifacts(Uint8List key) async {
    final verificationToken = CryptoService.encryptText(_verificationText, key);
    await _storage.write(key: _keyVerification, value: verificationToken);
    await _storage.write(key: _keyMasterKey, value: base64Encode(key));
  }
}
