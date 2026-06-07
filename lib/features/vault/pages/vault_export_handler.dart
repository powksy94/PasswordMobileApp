import 'package:flutter/material.dart';
import '../models/vault_item.dart';
import '../widgets/export_option_tile.dart';
import '../../../l10n/app_localizations.dart';
import './vault_export_actions.dart';

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
      title: Text(l.titleExportDialog),
      children: [
        ExportOptionTile(
          icon:     Icons.fingerprint,
          color:    Colors.cyanAccent,
          title:    l.exportOptionBiometricTitle,
          subtitle: l.exportOptionBiometricSubtitle,
          onTap: () {
            Navigator.pop(context);
            exportVaultBiometric(context, items);
          },
        ),
        ExportOptionTile(
          icon:     Icons.vpn_key,
          color:    Colors.greenAccent,
          title:    l.exportOptionPortableTitle,
          subtitle: l.exportOptionPortableSubtitle,
          onTap: () {
            Navigator.pop(context);
            exportVaultPortable(context, items);
          },
        ),
        ExportOptionTile(
          icon:     Icons.description,
          color:    Colors.orangeAccent,
          title:    l.exportOptionJsonTitle,
          subtitle: l.exportOptionJsonSubtitle,
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
