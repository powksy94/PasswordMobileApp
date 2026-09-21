import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import './vault_import_exceptions.dart';

/// Parses a generic CSV export (Chrome, Bitwarden, 1Password formats, etc.)
/// by detecting the separator and columns from common keywords.
///
/// Deliberately without any notion of PIN: the CSV only exists to import
/// from third-party tools, which have no such concept; this app itself
/// never exports to CSV (see VaultExportService/BiometricExportService,
/// which handle JSON and the encrypted format, both type-aware). Every CSV item is therefore
/// always a `type: 'password'` (default value of [VaultItem]).
class VaultCsvParser {
  static final _uuid = Uuid();

  /// [fallbackLabelPrefix] is used to name the rows without a recognizable
  /// title (e.g. "Import 3"); provided by the caller to stay localized.
  static List<VaultItem> parse(String content, {required String fallbackLabelPrefix}) {
    // Separator detection (, or ;)
    final firstLine = content.split('\n').first;
    final sep = firstLine.contains(';') ? ';' : ',';

    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) throw InvalidCsvFileException();

    // Normalized headers
    final headers = _splitLine(lines[0], sep)
        .map((h) => h.toLowerCase().trim())
        .toList();

    // Flexible mapping: common column names depending on the password managers
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
      if (pw.isEmpty) continue; // ignore the rows without a password

      final url   = urlIdx   >= 0 ? _cell(cells, urlIdx)   : '';
      final notes = notesIdx >= 0 ? _cell(cells, notesIdx) : '';

      // Label: service name, otherwise the URL, otherwise the fallback prefix
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

  /// Splits a CSV line while handling quoted fields.
  static List<String> _splitLine(String line, String sep) {
    final result  = <String>[];
    var   current = StringBuffer();
    var   inQuote = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        // Doubled quote = literal quote
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

  /// Finds the first index matching one of the candidate names.
  static int _col(List<String> headers, List<String> candidates) {
    for (final c in candidates) {
      final idx = headers.indexOf(c);
      if (idx >= 0) return idx;
    }
    return -1;
  }

  /// Value of a cell, cleaned of residual quotes.
  static String _cell(List<String> cells, int idx) {
    if (idx < 0 || idx >= cells.length) return '';
    return cells[idx].replaceAll(RegExp(r'^"+|"+$'), '');
  }
}
