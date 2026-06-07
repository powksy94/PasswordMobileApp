import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import 'vault_import_exceptions.dart';

/// Parse un export CSV générique (formats Chrome, Bitwarden, 1Password, etc.)
/// en détectant séparateur et colonnes par mots-clés courants.
class VaultCsvParser {
  static final _uuid = Uuid();

  /// [fallbackLabelPrefix] est utilisé pour nommer les lignes sans titre
  /// reconnaissable (ex. "Import 3") — fourni par l'appelant pour rester localisé.
  static List<VaultItem> parse(String content, {required String fallbackLabelPrefix}) {
    // Détection du séparateur (, ou ;)
    final firstLine = content.split('\n').first;
    final sep = firstLine.contains(';') ? ';' : ',';

    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) throw InvalidCsvFileException();

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

    if (passwordIdx == -1) throw CsvPasswordColumnMissingException(headers);

    final items = <VaultItem>[];
    for (int i = 1; i < lines.length; i++) {
      final cells = _splitLine(lines[i], sep);
      final pw = _cell(cells, passwordIdx);
      if (pw.isEmpty) continue; // ignore les lignes sans mot de passe

      final url   = urlIdx   >= 0 ? _cell(cells, urlIdx)   : '';
      final notes = notesIdx >= 0 ? _cell(cells, notesIdx) : '';

      // Label : nom du service, sinon l'URL, sinon le préfixe de repli
      String label = nameIdx >= 0 ? _cell(cells, nameIdx) : '';
      if (label.isEmpty && url.isNotEmpty) label = url;
      if (label.isEmpty) label = '$fallbackLabelPrefix $i';

      items.add(VaultItem(
        id:       _uuid.v4(),
        label:    label,
        login:    loginIdx >= 0 ? _cell(cells, loginIdx) : '',
        password: pw,
        notes:    notes,
        icon:     'lock',
        url:      url,
      ));
    }

    if (items.isEmpty) throw EmptyCsvImportException();
    return items;
  }

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
