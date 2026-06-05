import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_export_service.dart';
import '../../services/biometric_export_service.dart';
import '../../l10n/app_localizations.dart';

Future<void> showVaultExportDialog(
  BuildContext context,
  List<VaultItem> items,
) async {
  final l = AppLocalizations.of(context)!;

  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.vaultEmptyExport)),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text('Export'),
      children: [
        _ExportOption(
          icon:     Icons.fingerprint,
          color:    Colors.cyanAccent,
          title:    'Encrypted — biometric',
          subtitle: 'This device only. Requires fingerprint or PIN.',
          onTap: () {
            Navigator.pop(context);
            exportVaultBiometric(context, items);
          },
        ),
        _ExportOption(
          icon:     Icons.vpn_key,
          color:    Colors.greenAccent,
          title:    'Encrypted — portable',
          subtitle: 'Any device with your master password.',
          onTap: () {
            Navigator.pop(context);
            exportVaultPortable(context, items);
          },
        ),
        _ExportOption(
          icon:     Icons.description,
          color:    Colors.orangeAccent,
          title:    'JSON — plaintext',
          subtitle: '⚠️ Passwords readable by anyone.',
          onTap: () {
            Navigator.pop(context);
            exportVaultJson(context, items);
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.btnCancel),
        ),
      ],
    ),
  );
}

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
  final available = await BiometricExportService.isAvailable();
  if (!context.mounted) return;

  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biometrics unavailable — use portable export')),
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
      title:   const Text('Portable export'),
      content: const Text(
        'The file will be encrypted with your master password.\n\n'
        'It will be saved to your Downloads folder.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Export'),
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
      title:   const Text('JSON export'),
      content: const Text(
        '⚠️ This file will contain your passwords in plaintext.\n\n'
        'It will be saved to your Downloads folder.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Export'),
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

class _ExportOption extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       title;
  final String       subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
