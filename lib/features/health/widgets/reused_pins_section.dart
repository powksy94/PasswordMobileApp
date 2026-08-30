import 'package:flutter/material.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import './health_section_header.dart';
import './pin_health_item_tile.dart';
import '../../../l10n/app_localizations.dart';

/// Section "PINs réutilisés" de la page Santé.
class ReusedPinsSection extends StatelessWidget {
  final List<List<VaultItem>>   groups;
  final ValueChanged<VaultItem> onEdit;

  const ReusedPinsSection({
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
          title:    '${l.labelReusedPins} (${groups.length} ${l.labelGroupsCount})',
          subtitle: l.subtitleReusedPins,
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
                        '${group.length} ${l.labelSamePin}',
                        style: const TextStyle(
                          color:      Colors.orangeAccent,
                          fontSize:   12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...group.map((i) =>
                        PinHealthItemTile(item: i, onEdit: () => onEdit(i))),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
