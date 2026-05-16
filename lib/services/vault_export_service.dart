import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/vault_item.dart';

class VaultExportService {
  /// Exporte les items du vault en JSON non chiffré dans le dossier documents.
  /// Retourne le chemin complet du fichier créé.
  static Future<String> exportToJson(List<VaultItem> items) async {
    final dir       = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file      = File('${dir.path}/vault_export_$timestamp.json');

    final data = items.map((i) => {
      'label':    i.label,
      'login':    i.login,
      'password': i.password,
      'notes':    i.notes,
      'icon':     i.icon,
    }).toList();

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    return file.path;
  }
}
