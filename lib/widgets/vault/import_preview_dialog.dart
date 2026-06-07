import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../common/glass_panel.dart';
import '../../l10n/app_localizations.dart';

/// Aperçu des items détectés dans un fichier avant de confirmer leur import.
class ImportPreviewDialog extends StatelessWidget {
  final List<VaultItem> items;
  const ImportPreviewDialog({super.key, required this.items});

  static const _previewMax = 5;

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final accent   = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final preview  = items.take(_previewMax).toList();
    final overflow = items.length - _previewMax;

    return AlertDialog(
      title: Text('${items.length} ${l.labelPasswordsFound}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.bodyImportPreview,
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
                      '… +$overflow ${l.labelAndMore}',
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
          child: Text(l.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.btnImport),
        ),
      ],
    );
  }
}
