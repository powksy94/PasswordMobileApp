import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../common/glass_panel.dart';
import 'health_section_header.dart';
import 'health_item_tile.dart';
import '../../l10n/app_localizations.dart';

/// Section "Mots de passe faibles" de la page Santé des mots de passe.
class WeakPasswordsSection extends StatelessWidget {
  final List<VaultItem>           items;
  final ValueChanged<VaultItem>   onEdit;

  const WeakPasswordsSection({
    super.key,
    required this.items,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HealthSectionHeader(
          icon:     Icons.warning_amber_rounded,
          title:    '${l.labelWeakPasswords} (${items.length})',
          subtitle: l.subtitleWeakPasswords,
          color:    Colors.redAccent,
        ),
        const SizedBox(height: 8),
        GlassPanel(
          width:   double.infinity,
          padding: EdgeInsets.zero,
          child: Column(
            children: items
                .map((i) => HealthItemTile(item: i, onEdit: () => onEdit(i)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
