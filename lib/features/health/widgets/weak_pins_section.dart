import 'package:flutter/material.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import './health_section_header.dart';
import './pin_health_item_tile.dart';
import '../../../l10n/app_localizations.dart';

/// Section "PINs faibles" de la page Santé.
class WeakPinsSection extends StatelessWidget {
  final List<VaultItem>         items;
  final ValueChanged<VaultItem> onEdit;

  const WeakPinsSection({
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
          title:    '${l.labelWeakPins} (${items.length})',
          subtitle: l.subtitleWeakPins,
          color:    Colors.redAccent,
        ),
        const SizedBox(height: 8),
        GlassPanel(
          width:   double.infinity,
          padding: EdgeInsets.zero,
          child: Column(
            children: items
                .map((i) => PinHealthItemTile(item: i, onEdit: () => onEdit(i)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
