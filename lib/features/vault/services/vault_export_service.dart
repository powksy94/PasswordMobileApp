import 'dart:convert';
import 'dart:io';
import '../models/vault_item.dart';
import '../../../shared/utils/downloads_directory.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/services/crypto_service.dart';

class VaultExportService {
  // ── JSON (texte clair) → Téléchargements ─────────────────────────────────

  static Future<String> exportToJson(List<VaultItem> items) async {
    final dir       = await getDownloadsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file      = File('${dir.path}/vault_export_$timestamp.json');

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        items.map((i) => {
          'label':    i.label,
          'login':    i.login,
          'password': i.password,
          'notes':    i.notes,
          'icon':     i.icon,
        }).toList(),
      ),
    );
    return file.path;
  }

  // ── Chiffré portable (master password) → Téléchargements ─────────────────

  static Future<String> exportPortable(List<VaultItem> items) async {
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception('Master key absente — connectez-vous d\'abord');

    final jsonStr   = jsonEncode(items.map((i) => {
      'label': i.label, 'login': i.login,
      'password': i.password, 'notes': i.notes, 'icon': i.icon,
    }).toList());
    final encrypted = CryptoService.encryptText(jsonStr, key);

    final dir       = await getDownloadsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file      = File('${dir.path}/vault_portable_$timestamp.enc');
    await file.writeAsString(encrypted);
    return file.path;
  }
}
