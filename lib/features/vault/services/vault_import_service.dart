import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import '../../auth/services/master_key_service.dart';
import './biometric_export_service.dart';
import './biometric_prompt_texts.dart';
import '../../../shared/services/crypto_service.dart';
import './vault_csv_parser.dart';
import './vault_import_exceptions.dart';
import './vault_service.dart';

export 'vault_import_exceptions.dart';

class VaultImportService {
  static const _uuid = Uuid();

  // ── Reading and decryption ──────────────────────────────────────────────

  /// Reads a file from its path (fallback for the old calls).
  static Future<String> readPath(String filePath) =>
      File(filePath).readAsString();

  /// Parses the content of an already-read file, depending on its name (extension).
  /// [csvFallbackLabelPrefix] names the CSV rows without a recognizable title
  /// (e.g. "Import 3"), provided localized by the caller. [biometricPrompt] is used
  /// for the system prompt if the `.enc` file is decrypted via the device key.
  static Future<List<VaultItem>> parseContent(
    String content,
    String fileName, {
    required String csvFallbackLabelPrefix,
    required BiometricPromptTexts biometricPrompt,
  }) async {
    if (fileName.endsWith('.json')) return _parseJson(content);
    if (fileName.endsWith('.csv')) {
      return VaultCsvParser.parse(content, fallbackLabelPrefix: csvFallbackLabelPrefix);
    }

    if (fileName.endsWith('.enc')) {
      final masterKey = MasterKeyService.getMasterKey();
      if (masterKey != null) {
        try {
          return _parseJson(CryptoService.decryptText(content, masterKey));
        } catch (_) {}
      }

      final bioKey = await BiometricExportService.getKeyForDecrypt(biometricPrompt);
      if (bioKey != null) {
        try {
          return _parseJson(CryptoService.decryptText(content, bioKey));
        } catch (_) {}
      }

      throw ImportDecryptionFailedException();
    }

    throw UnsupportedImportFormatException();
  }

  // ── Import to the server ────────────────────────────────────────────────

  static Future<int> importItems(List<VaultItem> items) async {
    int count = 0;
    for (final item in items) {
      await VaultService.addToServer(
        type:     item.type,
        label:    item.label,
        login:    item.login,
        password: item.password,
        notes:    item.notes,
        icon:     item.icon,
        url:      item.url,
        pin:      item.pin,
      );
      count++;
    }
    return count;
  }

  // ── Parsers ───────────────────────────────────────────────────────────────

  static List<VaultItem> _parseJson(String content) {
    final data = jsonDecode(content) as List<dynamic>;
    return data.map((raw) {
      final m = raw as Map<String, dynamic>;
      return VaultItem(
        id:       _uuid.v4(),
        type:     m['type']     as String? ?? 'password',
        label:    m['label']    as String? ?? '',
        login:    m['login']    as String? ?? '',
        password: m['password'] as String? ?? '',
        notes:    m['notes']    as String? ?? '',
        icon:     m['icon']     as String? ?? 'lock',
        url:      m['url']      as String? ?? '',
        pin:      m['pin']      as String? ?? '',
      );
    }).toList();
  }
}
