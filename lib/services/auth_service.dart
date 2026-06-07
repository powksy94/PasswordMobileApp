// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Flag soft-logout : token conservé mais session marquée fermée
  static const _prefLoggedOut = 'session_logged_out';

  static const _verificationText = 'VAULT_VERIFY_v1';
  static final  ApiService _api  = ApiService();
  static Uint8List? _masterKey;

  // ── Register ─────────────────────────────────────────────────────────────────

  static Future<void> register(
      String email, String password, String masterPassword) async {
    final saltBytes  = pcSecureRandom(16);
    final saltBase64 = base64Encode(saltBytes);

    await _api.register(email, password, saltBase64);

    final key = CryptoService.deriveKey(masterPassword, saltBase64);
    _masterKey = key;

    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keySalt,  value: saltBase64);
    await _persistKeyArtifacts(key);
  }

  // ── Login ─────────────────────────────────────────────────────────────────────

  // ── Login étape 1 : authentification serveur uniquement ─────────────────────

  /// Vérifie email + mot de passe de connexion auprès du serveur.
  /// Retourne (token, role, salt) sans dériver la master key.
  static Future<({String token, String role, String salt})> loginToServer(
      String email, String password) async {
    final res = await _api.login(email, password);
    return (
      token: res['token'] as String,
      role:  res['role']  as String? ?? 'user',
      salt:  res['salt']  as String,
    );
  }

  // ── Login étape 2 : dérivation de la master key ───────────────────────────────

  /// Complète la connexion en dérivant et stockant la master key.
  /// Appelé après [loginToServer] une fois le mot de passe maître connu.
  static Future<void> completeLogin({
    required String token,
    required String role,
    required String salt,
    required String masterPassword,
    required String email,
  }) async {
    final key = CryptoService.deriveKey(masterPassword, salt);
    _masterKey = key;

    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole,  value: role);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keySalt,  value: salt);
    await _persistKeyArtifacts(key);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLoggedOut);
  }

  // ── Compat : login en une seule passe (interne) ───────────────────────────────
  static Future<void> login(
      String email, String password, String masterPassword) async {
    final s = await loginToServer(email, password);
    await completeLogin(
      token:          s.token,
      role:           s.role,
      salt:           s.salt,
      masterPassword: masterPassword,
      email:          email,
    );
  }

  // ── Logout (soft) ─────────────────────────────────────────────────────────────
  //
  // On garde le token + master key dans le storage pour permettre la reconnexion
  // biométrique. Le flag `session_logged_out` indique que la session est fermée.

  static Future<void> logout() async {
    _masterKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLoggedOut, true);
  }

  // Supprime tout (utilisé à la suppression de compte).
  static Future<void> fullLogout() async {
    _masterKey = null;
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keySalt);
    await _storage.delete(key: _keyVerification);
    await _storage.delete(key: _keyMasterKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLoggedOut);
  }

  // ── Vérifications de session ──────────────────────────────────────────────────

  /// Session active (token présent ET pas de flag logout).
  static Future<bool> isLoggedIn() async {
    final token     = await _storage.read(key: _keyToken);
    if (token == null) return false;
    final prefs     = await SharedPreferences.getInstance();
    final loggedOut = prefs.getBool(_prefLoggedOut) ?? false;
    return !loggedOut;
  }

  /// Token présent mais session fermée → reconnexion biométrique possible.
  static Future<bool> hasLoggedOutSession() async {
    final token     = await _storage.read(key: _keyToken);
    if (token == null) return false;
    final prefs     = await SharedPreferences.getInstance();
    return prefs.getBool(_prefLoggedOut) ?? false;
  }

  /// Restaure la session après auth biométrique réussie (local_auth).
  static Future<bool> restoreSessionAfterBiometric() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return false;
    final success = await unlockFromStorage(); // restaure master key
    if (!success) return false;
    // Lève le flag logged_out
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLoggedOut);
    return true;
  }

  // ── Auto-lock ─────────────────────────────────────────────────────────────────

  static void clearMasterKey() => _masterKey = null;

  static Future<bool> unlockWithMasterPassword(String masterPassword) async {
    final saltBase64 = await _storage.read(key: _keySalt);
    if (saltBase64 == null) return false;

    final key = CryptoService.deriveKey(masterPassword, saltBase64);

    final token = await _storage.read(key: _keyVerification);
    if (token == null) {
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

  static Future<bool> unlockFromStorage() async {
    final stored = await _storage.read(key: _keyMasterKey);
    if (stored == null) return false;
    _masterKey = Uint8List.fromList(base64Decode(stored));
    return true;
  }

  /// Active [key] comme nouvelle master key et la persiste (changement de mot de passe maître).
  static Future<void> commitNewMasterKey(Uint8List key) async {
    _masterKey = key;
    await _persistKeyArtifacts(key);
  }

  /// Dérive la clé qu'aurait [password] avec le sel du compte courant (sans l'activer).
  static Future<Uint8List?> deriveKeyFromMasterPassword(String password) async {
    final saltBase64 = await _storage.read(key: _keySalt);
    if (saltBase64 == null) return null;
    return CryptoService.deriveKey(password, saltBase64);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  static Future<String?> getToken()          => _storage.read(key: _keyToken);
  static Future<String?> getRole()           => _storage.read(key: _keyRole);
  static Uint8List?      getMasterKey()      => _masterKey;
  static Future<String>  getUserRoleString() async =>
      await _storage.read(key: _keyRole) ?? 'user';

  static Future<void> updateTokenAndRole(String newToken, String role) async {
    await _storage.write(key: _keyToken, value: newToken);
    await _storage.write(key: _keyRole,  value: role);
  }

  static Uint8List pcSecureRandom(int length) {
    final rnd = Random.secure();
    final out = Uint8List(length);
    for (int i = 0; i < length; i++) {
      out[i] = rnd.nextInt(256);
    }
    return out;
  }

  static Future<void> _persistKeyArtifacts(Uint8List key) async {
    final verificationToken = CryptoService.encryptText(_verificationText, key);
    await _storage.write(key: _keyVerification, value: verificationToken);
    await _storage.write(key: _keyMasterKey,    value: base64Encode(key));
  }
}
