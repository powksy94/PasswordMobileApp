import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/services/crypto_service.dart';
import '../../vault/services/vault_cache.dart';
import './master_password_verifier.dart';

class MasterKeyService {
  static const _storage = FlutterSecureStorage();

  static const _keySalt          = 'auth_salt';
  static const _keyVerification  = 'key_verification';
  static const _keyMasterKey     = 'master_key_b64';
  static const _verificationText = 'VAULT_VERIFY_v1';

  static Uint8List? _masterKey;

  // ── Accessors ────────────────────────────────────────────────────────────────

  static Uint8List? getMasterKey()   => _masterKey;
  static void       clearMasterKey() => _masterKey = null;

  /// Adopts a key obtained through an external route (e.g. [BiometricUnlockService]
  /// after a hardware-backed biometric check) as the current master key,
  /// without re-deriving or rewriting the password verification artifacts
  /// (already in place since the last login/derivation).
  static void setUnlockedKey(Uint8List key) => _masterKey = key;

  // ── Setup from login / register ─────────────────────────────────────────────

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
      // No local reference: rather than blindly adopting the input
      // (a typo would become the reference), cross-check it against the
      // vault cache when it exists. Without a cache, we cannot decide.
      if (await _contradictsCachedVault(key)) return false;
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

  /// Key persisted by the last login/derivation, without adopting it as the
  /// current key. Used to detect that a new derivation produces a different
  /// key (other account, master password changed elsewhere).
  static Future<Uint8List?> readPersistedKey() async {
    final stored = await _storage.read(key: _keyMasterKey);
    if (stored == null) return null;
    return Uint8List.fromList(base64Decode(stored));
  }

  static Future<bool> unlockFromStorage() async {
    final stored = await _storage.read(key: _keyMasterKey);
    if (stored == null) return false;
    _masterKey = Uint8List.fromList(base64Decode(stored));
    return true;
  }

  // ── Master key change ──────────────────────────────────────────────────

  static Future<void> commitNewMasterKey(Uint8List key) async {
    _masterKey = key;
    await _persistKeyArtifacts(key);
  }

  static Future<Uint8List?> deriveKeyFromMasterPassword(String password) async {
    final saltBase64 = await _storage.read(key: _keySalt);
    if (saltBase64 == null) return null;
    return CryptoService.deriveKey(password, saltBase64);
  }

  // ── Reset (vault purge + new key) ──────────────────────────────────────

  /// Derives a new key from [newMasterPassword] + the existing salt,
  /// without checking the old key. Use only after the vault has been purged.
  static Future<bool> resetMasterKey(String newMasterPassword) async {
    final salt = await _storage.read(key: _keySalt);
    if (salt == null) return false;
    final key = CryptoService.deriveKey(newMasterPassword, salt);
    _masterKey = key;
    await _persistKeyArtifacts(key);
    return true;
  }

  // ── Full deletion ──────────────────────────────────────────────────────

  static Future<void> deleteAll() async {
    await _storage.delete(key: _keySalt);
    await _storage.delete(key: _keyVerification);
    await _storage.delete(key: _keyMasterKey);
  }

  // ── Utilities ───────────────────────────────────────────────────────────────

  static Uint8List pcSecureRandom(int length) {
    final rnd = Random.secure();
    final out = Uint8List(length);
    for (int i = 0; i < length; i++) { out[i] = rnd.nextInt(256); }
    return out;
  }

  static Future<bool> _contradictsCachedVault(Uint8List key) async {
    try {
      final cached = await VaultCache.load();
      if (cached == null) return false;
      return MasterPasswordVerifier.probe(cached, key) == MasterPasswordCheck.mismatch;
    } catch (_) {
      return false; // unreadable cache: we do not block the user
    }
  }

  static Future<void> _persistKeyArtifacts(Uint8List key) async {
    final token = CryptoService.encryptText(_verificationText, key);
    await _storage.write(key: _keyVerification, value: token);
    await _storage.write(key: _keyMasterKey,    value: base64Encode(key));
  }
}
