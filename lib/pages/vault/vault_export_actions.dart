import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_export_service.dart';
import '../../services/biometric_export_service.dart';
import '../../l10n/app_localizations.dart';

void _snackSuccess(BuildContext context, String path) {
  final filename = path.split('/').last;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:  Text('✅ $filename'),
      duration: const Duration(seconds: 5),
    ),
  );
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
    final path = await BiometricExportService.exportEncrypted(items);
    if (!context.mounted) return;
    if (path == null) return;
    _snackSuccess(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
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
    _snackSuccess(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
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
    _snackSuccess(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
