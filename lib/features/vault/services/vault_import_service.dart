import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import '../../auth/services/master_key_service.dart';
import './biometric_export_service.dart';
import '../../../shared/services/crypto_service.dart';
import './vault_csv_parser.dart';
import './vault_import_exceptions.dart';
import './vault_service.dart';

export 'vault_import_exceptions.dart';

class VaultImportService {
  static const _uuid = Uuid();

  // ── Lecture et déchiffrement ──────────────────────────────────────────────

  /// Lit un fichier depuis son chemin (fallback pour les anciens appels).
  static Future<String> readPath(String filePath) =>
      File(filePath).readAsString();

  /// Parse le contenu d'un fichier déjà lu, selon son nom (extension).
  /// [csvFallbackLabelPrefix] nomme les lignes CSV sans titre reconnaissable
  /// (ex. "Import 3") — fourni localisé par l'appelant.
  static Future<List<VaultItem>> parseContent(
    String content,
    String fileName, {
    required String csvFallbackLabelPrefix,
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

      final bioKey = await BiometricExportService.getKeyForDecrypt();
      if (bioKey != null) {
        try {
          return _parseJson(CryptoService.decryptText(content, bioKey));
        } catch (_) {}
      }

      throw ImportDecryptionFailedException();
    }

    throw UnsupportedImportFormatException();
  }

  // ── Import vers le serveur ────────────────────────────────────────────────

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
