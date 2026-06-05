import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_import_service.dart';
import '../../widgets/common/glass_panel.dart';
import '../../l10n/app_localizations.dart';

/// Orchestre le flux d'import : sélection fichier → aperçu → confirmation → import.
Future<bool> showVaultImportDialog(BuildContext context) async {
  // 1. Sélection du fichier (withData pour Android scoped storage)
  final result = await FilePicker.platform.pickFiles(
    type:              FileType.custom,
    allowedExtensions: ['enc', 'json', 'csv'],
    dialogTitle:       'Sélectionner un fichier vault (.enc, .json, .csv)',
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
          const SnackBar(content: Text('Impossible de lire le fichier.')),
        );
      }
      return false;
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lecture échouée : $e')),
      );
    }
    return false;
  }

  if (!context.mounted) return false;

  // 2. Parsing et déchiffrement
  List<VaultItem> items;
  try {
    items = await VaultImportService.parseContent(content, fileName);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 6)),
      );
    }
    return false;
  }

  if (!context.mounted) return false;
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le fichier ne contient aucun item.')),
    );
    return false;
  }

  // 3. Aperçu et confirmation
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _ImportPreviewDialog(items: items),
  );
  if (confirmed != true || !context.mounted) return false;

  // 4. Import
  try {
    final count = await VaultImportService.importItems(items);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $count mot(s) de passe importé(s)')),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur import : $e')),
      );
    }
    return false;
  }
}

// ── Dialog d'aperçu ────────────────────────────────────────────────────────────

class _ImportPreviewDialog extends StatelessWidget {
  final List<VaultItem> items;
  const _ImportPreviewDialog({required this.items});

  static const _previewMax = 5;

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final accent   = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final preview  = items.take(_previewMax).toList();
    final overflow = items.length - _previewMax;

    return AlertDialog(
      title: Text('${items.length} mot(s) de passe trouvé(s)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Les items suivants seront ajoutés à votre vault. '
            'Les éventuels doublons seront conservés.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          GlassPanel(
            width:   double.infinity,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ...preview.map((i) => ListTile(
                      dense:       true,
                      leading:     Icon(Icons.lock_outline, color: accent, size: 18),
                      title:       Text(i.label,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          )),
                      subtitle: i.login.isNotEmpty
                          ? Text(i.login,
                              style: const TextStyle(fontSize: 11))
                          : null,
                    )),
                if (overflow > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text(
                      '… et $overflow autre(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)!.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Importer'),
        ),
      ],
    );
  }
}
