import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import 'auth_service.dart';
import 'biometric_export_service.dart';
import 'crypto_service.dart';
import 'vault_service.dart';

class VaultImportService {
  static const _uuid = Uuid();

  // ── Lecture et déchiffrement ──────────────────────────────────────────────

  /// Lit un fichier .enc, .json ou .csv et retourne la liste des items.
  static Future<List<VaultItem>> parseFile(String filePath) async {
    final content = await File(filePath).readAsString();
    final lower   = filePath.toLowerCase();

    if (lower.endsWith('.json')) return _parseJson(content);
    if (lower.endsWith('.csv'))  return _parseCsv(content);

    if (lower.endsWith('.enc')) {
      // Tentative 1 : clé portable (master key en mémoire, silencieux)
      final masterKey = AuthService.getMasterKey();
      if (masterKey != null) {
        try {
          return _parseJson(CryptoService.decryptText(content, masterKey));
        } catch (_) {}
      }

      // Tentative 2 : clé biométrique (déclenche la dialog d'empreinte)
      final bioKey = await BiometricExportService.getKeyForDecrypt();
      if (bioKey != null) {
        try {
          return _parseJson(CryptoService.decryptText(content, bioKey));
        } catch (_) {}
      }

      throw Exception(
        'Impossible de déchiffrer ce fichier.\n\n'
        '• Vérifiez que vous êtes connecté avec le bon compte\n'
        '• Ou que vous utilisez l\'empreinte de l\'appareil d\'origine',
      );
    }

    throw Exception(
        'Format non supporté. Sélectionnez un fichier .enc, .json ou .csv.');
  }

  // ── Import vers le serveur ────────────────────────────────────────────────

  static Future<int> importItems(List<VaultItem> items) async {
    int count = 0;
    for (final item in items) {
      await VaultService.addToServer(
        label:    item.label,
        login:    item.login,
        password: item.password,
        notes:    item.notes,
        icon:     item.icon,
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
        label:    m['label']    as String? ?? '',
        login:    m['login']    as String? ?? '',
        password: m['password'] as String? ?? '',
        notes:    m['notes']    as String? ?? '',
        icon:     m['icon']     as String? ?? 'lock',
      );
    }).toList();
  }

  static List<VaultItem> _parseCsv(String content) {
    // Détection du séparateur (, ou ;)
    final firstLine = content.split('\n').first;
    final sep = firstLine.contains(';') ? ';' : ',';

    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) throw Exception('Le fichier CSV est vide ou invalide.');

    // En-têtes normalisés
    final headers = _splitLine(lines[0], sep)
        .map((h) => h.toLowerCase().trim())
        .toList();

    // Mapping flexible : noms de colonnes courants selon les gestionnaires
    final nameIdx     = _col(headers, ['name', 'title', 'label', 'nom', 'libellé', 'service']);
    final loginIdx    = _col(headers, ['username', 'login', 'user', 'email', 'utilisateur', 'login_username']);
    final passwordIdx = _col(headers, ['password', 'pass', 'passwd', 'mot de passe', 'login_password']);
    final notesIdx    = _col(headers, ['notes', 'note', 'extra', 'comment', 'memo', 'description']);
    final urlIdx      = _col(headers, ['url', 'website', 'site', 'login_uri', 'uri']);

    if (passwordIdx == -1) {
      throw Exception(
        'Colonne "password" introuvable.\n'
        'Colonnes détectées : ${headers.join(', ')}',
      );
    }

    final items = <VaultItem>[];
    for (int i = 1; i < lines.length; i++) {
      final cells = _splitLine(lines[i], sep);
      final pw = _cell(cells, passwordIdx);
      if (pw.isEmpty) continue; // ignore les lignes sans mot de passe

      // Le label : nom du service, sinon l'URL, sinon "Import N"
      String label = nameIdx >= 0 ? _cell(cells, nameIdx) : '';
      if (label.isEmpty && urlIdx >= 0) label = _cell(cells, urlIdx);
      if (label.isEmpty) label = 'Import $i';

      // Les notes : notes + URL (si URL non utilisée comme label)
      String notes = notesIdx >= 0 ? _cell(cells, notesIdx) : '';
      if (urlIdx >= 0 && nameIdx >= 0) {
        final url = _cell(cells, urlIdx);
        if (url.isNotEmpty) notes = notes.isEmpty ? url : '$url\n$notes';
      }

      items.add(VaultItem(
        id:       _uuid.v4(),
        label:    label,
        login:    loginIdx >= 0 ? _cell(cells, loginIdx) : '',
        password: pw,
        notes:    notes,
        icon:     'lock',
      ));
    }

    if (items.isEmpty) throw Exception('Aucun mot de passe trouvé dans le fichier CSV.');
    return items;
  }

  // ── Helpers CSV ───────────────────────────────────────────────────────────

  /// Découpe une ligne CSV en gérant les champs entre guillemets.
  static List<String> _splitLine(String line, String sep) {
    final result  = <String>[];
    var   current = StringBuffer();
    var   inQuote = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        // Guillemet doublé = guillemet littéral
        if (inQuote && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuote = !inQuote;
        }
      } else if (ch == sep && !inQuote) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(ch);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  /// Cherche le premier index correspondant à un des noms candidats.
  static int _col(List<String> headers, List<String> candidates) {
    for (final c in candidates) {
      final idx = headers.indexOf(c);
      if (idx >= 0) return idx;
    }
    return -1;
  }

  /// Valeur d'une cellule, nettoyée des guillemets résiduels.
  static String _cell(List<String> cells, int idx) {
    if (idx < 0 || idx >= cells.length) return '';
    return cells[idx].replaceAll(RegExp(r'^"+|"+$'), '');
  }
}
