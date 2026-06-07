import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../common/glass_panel.dart';
import 'health_section_header.dart';
import 'health_item_tile.dart';
import '../../l10n/app_localizations.dart';

/// Section "Mots de passe réutilisés" de la page Santé des mots de passe.
class ReusedPasswordsSection extends StatelessWidget {
  final List<List<VaultItem>>   groups;
  final ValueChanged<VaultItem> onEdit;

  const ReusedPasswordsSection({
    super.key,
    required this.groups,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HealthSectionHeader(
          icon:     Icons.copy_all,
          title:    '${l.labelReusedPasswords} (${groups.length} ${l.labelGroupsCount})',
          subtitle: l.subtitleReusedPasswords,
          color:    Colors.orangeAccent,
        ),
        const SizedBox(height: 8),
        ...groups.map((group) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassPanel(
                width:   double.infinity,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Text(
                        '${group.length} ${l.labelSameServicesPassword}',
                        style: const TextStyle(
                          color:      Colors.orangeAccent,
                          fontSize:   12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...group.map((i) =>
                        HealthItemTile(item: i, onEdit: () => onEdit(i))),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
