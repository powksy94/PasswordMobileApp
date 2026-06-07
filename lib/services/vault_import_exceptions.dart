/// Levée par [VaultImportService.parseContent] quand l'extension du fichier
/// n'est ni `.enc`, `.json` ni `.csv`.
class UnsupportedImportFormatException implements Exception {}

/// Levée quand un fichier `.enc` ne peut être déchiffré ni avec la master key
/// du compte courant, ni avec la clé biométrique de l'appareil.
class ImportDecryptionFailedException implements Exception {}

/// Levée par le parseur CSV quand le fichier est vide ou ne contient pas
/// au moins un en-tête et une ligne de données.
class InvalidCsvFileException implements Exception {}

/// Levée quand aucune colonne ne correspond à un mot de passe.
/// [headers] contient les en-têtes détectés, pour aider l'utilisateur
/// à comprendre pourquoi le fichier a été rejeté.
class CsvPasswordColumnMissingException implements Exception {
  final List<String> headers;
  CsvPasswordColumnMissingException(this.headers);
}

/// Levée quand le CSV est valide mais qu'aucune ligne n'a pu être convertie
/// en item exploitable (toutes les lignes ont un mot de passe vide).
class EmptyCsvImportException implements Exception {}
