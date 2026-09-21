import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/vault_item.dart';
import '../services/vault_export_service.dart';
import '../services/biometric_export_service.dart';
import '../services/biometric_prompt_texts.dart';
import '../../../shared/utils/error_message.dart';
import '../../../l10n/app_localizations.dart';

/// The exported file is written to an app-private folder (see
/// getExportScratchDirectory): under scoped storage (Android 10+), we cannot
/// guarantee that a public "Download/" path is writable. The
/// system share sheet lets the user choose the real
/// destination (Files, Drive, email...).
Future<void> _shareExportedFile(BuildContext context, String path) async {
  await Share.shareXFiles([XFile(path)]);
}

Future<void> exportVaultBiometric(
  BuildContext context,
  List<VaultItem> items,
) async {
  final l = AppLocalizations.of(context)!;
  final available = await BiometricExportService.isAvailable();
  if (!context.mounted) return;

  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.errorBiometricExportUnavailable)),
    );
    return;
  }

  try {
    final path = await BiometricExportService.exportEncrypted(
      items,
      BiometricPromptTexts.forExport(l),
    );
    if (!context.mounted) return;
    if (path == null) return;
    await _shareExportedFile(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }
}

Future<void> exportVaultPortable(
  BuildContext context,
  List<VaultItem> items,
) async {
  final l = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title:   Text(l.titlePortableExport),
      content: Text(l.bodyPortableExport),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.btnExport),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final path = await VaultExportService.exportPortable(items);
    if (!context.mounted) return;
    await _shareExportedFile(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }
}

Future<void> exportVaultJson(
  BuildContext context,
  List<VaultItem> items,
) async {
  final l = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title:   Text(l.titleJsonExport),
      content: Text(l.bodyJsonExport),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.btnExport),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final path = await VaultExportService.exportToJson(items);
    if (!context.mounted) return;
    await _shareExportedFile(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }
}
