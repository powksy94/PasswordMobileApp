import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/vault_item.dart';
import '../services/vault_import_service.dart';
import '../widgets/import_preview_dialog.dart';
import '../../../l10n/app_localizations.dart';

/// Orchestre le flux d'import : sélection fichier → aperçu → confirmation → import.
Future<bool> showVaultImportDialog(BuildContext context) async {
  final l = AppLocalizations.of(context)!;

  // 1. Sélection du fichier (withData pour Android scoped storage)
  final result = await FilePicker.platform.pickFiles(
    type:              FileType.custom,
    allowedExtensions: ['enc', 'json', 'csv'],
    dialogTitle:       l.dialogTitleSelectVaultFile,
    withData:          true,
  );
  if (result == null) return false;

  final file = result.files.single;
  final String fileName = file.name.toLowerCase();

  // Lecture du contenu : path d'abord, bytes en fallback
  String content;
  try {
    if (file.path != null) {
      content = await VaultImportService.readPath(file.path!);
    } else if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorCannotReadFile)),
        );
      }
      return false;
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.errorFileReadFailed}: $e')),
      );
    }
    return false;
  }

  if (!context.mounted) return false;

  // 2. Parsing et déchiffrement
  List<VaultItem> items;
  try {
    items = await VaultImportService.parseContent(
      content,
      fileName,
      csvFallbackLabelPrefix: l.labelImportFallbackPrefix,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_importErrorMessage(l, e)), duration: const Duration(seconds: 6)),
      );
    }
    return false;
  }

  if (!context.mounted) return false;
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.errorImportFileEmpty)),
    );
    return false;
  }

  // 3. Aperçu et confirmation
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ImportPreviewDialog(items: items),
  );
  if (confirmed != true || !context.mounted) return false;

  // 4. Import
  try {
    final count = await VaultImportService.importItems(items);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $count ${l.labelPasswordsImported}')),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.errorImportFailed}: $e')),
      );
    }
    return false;
  }
}

/// Traduit une exception de [VaultImportService.parseContent] en message localisé.
String _importErrorMessage(AppLocalizations l, Object e) {
  if (e is UnsupportedImportFormatException) return l.errorUnsupportedImportFormat;
  if (e is ImportDecryptionFailedException)  return l.errorImportDecryptionFailed;
  if (e is InvalidCsvFileException)          return l.errorInvalidCsvFile;
  if (e is CsvPasswordColumnMissingException) {
    return '${l.errorCsvPasswordColumnMissing}\n${l.labelDetectedColumns}: ${e.headers.join(', ')}';
  }
  if (e is EmptyCsvImportException) return l.errorEmptyCsvImport;
  return e.toString();
}
