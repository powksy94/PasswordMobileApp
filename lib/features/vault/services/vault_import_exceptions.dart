/// Thrown by [VaultImportService.parseContent] when the file extension
/// is neither `.enc`, `.json` nor `.csv`.
class UnsupportedImportFormatException implements Exception {}

/// Thrown when an `.enc` file can be decrypted neither with the master key
/// of the current account nor with the device's biometric key.
class ImportDecryptionFailedException implements Exception {}

/// Thrown by the CSV parser when the file is empty or does not contain
/// at least one header and one data row.
class InvalidCsvFileException implements Exception {}

/// Thrown when no column matches a password.
/// [headers] contains the detected headers, to help the user
/// understand why the file was rejected.
class CsvPasswordColumnMissingException implements Exception {
  final List<String> headers;
  CsvPasswordColumnMissingException(this.headers);
}

/// Thrown when the CSV is valid but no row could be converted
/// into a usable item (all rows have an empty password).
class EmptyCsvImportException implements Exception {}
