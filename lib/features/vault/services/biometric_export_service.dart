import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:biometric_storage/biometric_storage.dart';
import '../models/vault_item.dart';
import './biometric_prompt_texts.dart';
import '../../../shared/utils/downloads_directory.dart';
import '../../../shared/services/crypto_service.dart';

/// Export of the vault encrypted with a key stored in the hardware Keystore.
///
/// Android Keystore / iOS Secure Enclave: the key can only be read after
/// biometric authentication (or fallback PIN). The `.enc` file is
/// therefore unreadable without this physical device + fingerprint.
class BiometricExportService {
  static const _storeName = 'vault_export_key_v1';

  // ── Availability ──────────────────────────────────────────────────────────

  static Future<bool> isAvailable() async {
    final result = await BiometricStorage().canAuthenticate();
    return result == CanAuthenticateResponse.success;
  }

  // ── Biometric-protected AES key ─────────────────────────────────────────────

  /// Reads or creates the AES key in the Keystore (triggers biometrics).
  static Future<Uint8List?> _getOrCreateKey(BiometricPromptTexts prompt) async {
    final store = await BiometricStorage().getStorage(
      _storeName,
      options: StorageFileInitOptions(
        authenticationRequired:                true,
        // -1 = always ask for the fingerprint, no validity window
        // androidBiometricOnly: true required with -1 (no PIN fallback)
        authenticationValidityDurationSeconds: -1,
        androidBiometricOnly:                  true,
      ),
      promptInfo: prompt.toPromptInfo(),
    );

    final stored = await store.read();
    if (stored == null) {
      final rng = Random.secure();
      final key = Uint8List.fromList(
          List.generate(32, (_) => rng.nextInt(256)));
      await store.write(base64Encode(key));
      return key;
    }
    return base64Decode(stored);
  }

  // ── Import: retrieves the key to decrypt an existing file ─────────────

  /// Triggers biometrics and returns the stored encryption key.
  /// Returns null if unavailable or if the user cancels.
  static Future<Uint8List?> getKeyForDecrypt(BiometricPromptTexts prompt) async {
    try {
      final store = await BiometricStorage().getStorage(
        _storeName,
        options: StorageFileInitOptions(
          authenticationRequired:                true,
          authenticationValidityDurationSeconds: -1,
          androidBiometricOnly:                  true,
        ),
        promptInfo: prompt.toPromptInfo(),
      );
      final stored = await store.read();
      if (stored == null) return null;
      return Uint8List.fromList(base64Decode(stored));
    } catch (_) {
      return null;
    }
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  /// Encrypts the items and writes an `.enc` file in the documents folder.
  /// Returns the file path, or `null` if the user cancelled.
  static Future<String?> exportEncrypted(
    List<VaultItem> items,
    BiometricPromptTexts prompt,
  ) async {
    try {
      final key = await _getOrCreateKey(prompt);
      if (key == null) return null;

      final jsonStr = jsonEncode(items
          .map((i) => {
                'type':     i.type,
                'label':    i.label,
                'login':    i.login,
                'password': i.password,
                'notes':    i.notes,
                'icon':     i.icon,
                'pin':      i.pin,
              })
          .toList());

      // Produces {"data":"...","iv":"..."} - same AES-GCM format as the vault
      final encrypted = CryptoService.encryptText(jsonStr, key);

      final dir       = await getExportScratchDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file      = File('${dir.path}/vault_secure_$timestamp.enc');
      await file.writeAsString(encrypted);
      return file.path;
    } on AuthException catch (e) {
      if (e.code == AuthExceptionCode.userCanceled ||
          e.code == AuthExceptionCode.canceled) {
        return null; // Cancelled -> silence
      }
      rethrow;
    }
  }
}
