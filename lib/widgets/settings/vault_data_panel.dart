import 'package:flutter/material.dart';
import '../common/glass_panel.dart';
import '../../l10n/app_localizations.dart';
import '../../services/vault_service.dart';
import '../../pages/vault/vault_export_handler.dart';
import '../../pages/vault/vault_import_handler.dart';

class VaultDataPanel extends StatelessWidget {
  const VaultDataPanel({super.key});

  // Ouvre showVaultExportDialog, qui propose 3 options : biométrique, portable, texte brut.
  Future<void> _export(BuildContext context) async {
    try {
      final result = await VaultService.loadFromServer();
      if (context.mounted) await showVaultExportDialog(context, result.items);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _import(BuildContext context) async {
    final imported = await showVaultImportDialog(context);
    if (imported) VaultService.vaultVersion.value++;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.titleVaultData,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.download_rounded),
            title: Text(l.tooltipImport),
            onTap: () => _import(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.upload_file),
            title: Text(l.tooltipExport),
            onTap: () => _export(context),
          ),
        ],
      ),
    );
  }
}
