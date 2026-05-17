import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:biometric_storage/biometric_storage.dart';
import '../models/vault_item.dart';
import '../utils/downloads_directory.dart';
import 'crypto_service.dart';

/// Export du vault chiffré avec une clé stockée dans le Keystore hardware.
///
/// Android Keystore / iOS Secure Enclave : la clé ne peut être lue qu'après
/// authentification biométrique (ou PIN de secours). Le fichier `.enc` est
/// donc illisible sans cet appareil physique + empreinte.
class BiometricExportService {
  static const _storeName = 'vault_export_key_v1';

  static final _promptInfo = const PromptInfo(
    androidPromptInfo: AndroidPromptInfo(
      title:          'Déverrouillez l\'export',
      subtitle:       'Accès à la clé de chiffrement du vault',
      negativeButton: 'Annuler',
    ),
    iosPromptInfo: IosPromptInfo(
      saveTitle:   'Déverrouillez l\'export',
      accessTitle: 'Déverrouillez l\'export',
    ),
  );

  // ── Disponibilité ──────────────────────────────────────────────────────────

  static Future<bool> isAvailable() async {
    final result = await BiometricStorage().canAuthenticate();
    return result == CanAuthenticateResponse.success;
  }

  // ── Clé AES protégée biométrie ─────────────────────────────────────────────

  /// Lit ou crée la clé AES dans le Keystore (déclenche la biométrie).
  static Future<Uint8List?> _getOrCreateKey() async {
    final store = await BiometricStorage().getStorage(
      _storeName,
      options: StorageFileInitOptions(
        authenticationRequired:                true,
        // -1 = toujours demander l'empreinte, sans fenêtre de validité
        // androidBiometricOnly: true requis avec -1 (pas de fallback PIN)
        authenticationValidityDurationSeconds: -1,
        androidBiometricOnly:                  true,
      ),
      promptInfo: _promptInfo,
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

  // ── Import : récupère la clé pour déchiffrer un fichier existant ─────────────

  /// Déclenche la biométrie et retourne la clé de chiffrement stockée.
  /// Retourne null si non dispo ou si l'utilisateur annule.
  static Future<Uint8List?> getKeyForDecrypt() async {
    try {
      final store = await BiometricStorage().getStorage(
        _storeName,
        options: StorageFileInitOptions(
          authenticationRequired:                true,
          authenticationValidityDurationSeconds: -1,
          androidBiometricOnly:                  true,
        ),
        promptInfo: _promptInfo,
      );
      final stored = await store.read();
      if (stored == null) return null;
      return Uint8List.fromList(base64Decode(stored));
    } catch (_) {
      return null;
    }
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  /// Chiffre les items et écrit un fichier `.enc` dans les documents.
  /// Retourne le chemin du fichier, ou `null` si l'utilisateur a annulé.
  static Future<String?> exportEncrypted(List<VaultItem> items) async {
    try {
      final key = await _getOrCreateKey();
      if (key == null) return null;

      final jsonStr = jsonEncode(items
          .map((i) => {
                'label':    i.label,
                'login':    i.login,
                'password': i.password,
                'notes':    i.notes,
                'icon':     i.icon,
              })
          .toList());

      // Produit {"data":"...","iv":"..."} — même format AES-GCM que le vault
      final encrypted = CryptoService.encryptText(jsonStr, key);

      final dir       = await getDownloadsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file      = File('${dir.path}/vault_secure_$timestamp.enc');
      await file.writeAsString(encrypted);
      return file.path;
    } on AuthException catch (e) {
      if (e.code == AuthExceptionCode.userCanceled ||
          e.code == AuthExceptionCode.canceled) {
        return null; // Annulé → silence
      }
      rethrow;
    }
  }
}
