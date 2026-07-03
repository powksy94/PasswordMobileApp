import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/services/crypto_service.dart';

class MasterKeyService {
  static const _storage = FlutterSecureStorage();

  static const _keySalt          = 'auth_salt';
  static const _keyVerification  = 'key_verification';
  static const _keyMasterKey     = 'master_key_b64';
  static const _verificationText = 'VAULT_VERIFY_v1';

  static Uint8List? _masterKey;

  // ── Accesseurs ────────────────────────────────────────────────────────────────

  static Uint8List? getMasterKey()   => _masterKey;
  static void       clearMasterKey() => _masterKey = null;

  // ── Setup depuis login / register ─────────────────────────────────────────────

  static Future<void> setupFromLogin(String salt, String masterPassword) async {
    await _storage.write(key: _keySalt, value: salt);
    final key = CryptoService.deriveKey(masterPassword, salt);
    _masterKey = key;
    await _persistKeyArtifacts(key);
  }

  // ── Unlock ────────────────────────────────────────────────────────────────────

  static Future<bool> unlockWithMasterPassword(String masterPassword) async {
    final saltBase64 = await _storage.read(key: _keySalt);
    if (saltBase64 == null) return false;

    final key    = CryptoService.deriveKey(masterPassword, saltBase64);
    final stored = await _storage.read(key: _keyVerification);

    if (stored == null) {
      _masterKey = key;
      await _persistKeyArtifacts(key);
      return true;
    }

    try {
      if (CryptoService.decryptText(stored, key) != _verificationText) return false;
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

  // ── Changement de clé maître ──────────────────────────────────────────────────

  static Future<void> commitNewMasterKey(Uint8List key) async {
    _masterKey = key;
    await _persistKeyArtifacts(key);
  }

  static Future<Uint8List?> deriveKeyFromMasterPassword(String password) async {
    final saltBase64 = await _storage.read(key: _keySalt);
    if (saltBase64 == null) return null;
    return CryptoService.deriveKey(password, saltBase64);
  }

  // ── Reset (purge coffre + nouvelle clé) ──────────────────────────────────────

  /// Dérive une nouvelle clé depuis [newMasterPassword] + le sel existant,
  /// sans vérifier l'ancienne clé. À utiliser uniquement après purge du coffre.
  static Future<bool> resetMasterKey(String newMasterPassword) async {
    final salt = await _storage.read(key: _keySalt);
    if (salt == null) return false;
    final key = CryptoService.deriveKey(newMasterPassword, salt);
    _masterKey = key;
    await _persistKeyArtifacts(key);
    return true;
  }

  // ── Suppression complète ──────────────────────────────────────────────────────

  static Future<void> deleteAll() async {
    await _storage.delete(key: _keySalt);
    await _storage.delete(key: _keyVerification);
    await _storage.delete(key: _keyMasterKey);
  }

  // ── Utilitaires ───────────────────────────────────────────────────────────────

  static Uint8List pcSecureRandom(int length) {
    final rnd = Random.secure();
    final out = Uint8List(length);
    for (int i = 0; i < length; i++) { out[i] = rnd.nextInt(256); }
    return out;
  }

  static Future<void> _persistKeyArtifacts(Uint8List key) async {
    final token = CryptoService.encryptText(_verificationText, key);
    await _storage.write(key: _keyVerification, value: token);
    await _storage.write(key: _keyMasterKey,    value: base64Encode(key));
  }
}
