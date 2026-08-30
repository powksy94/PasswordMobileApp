import 'package:flutter/material.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/utils/pin_score.dart';
import './weak_pins_section.dart';
import './reused_pins_section.dart';
import './health_all_good_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Section "Santé des PINs" : analyse (faibles, réutilisés) et rendu,
/// entièrement autonome à partir des items PIN fournis par la page.
class PinHealthSection extends StatelessWidget {
  final List<VaultItem>         items;
  final ValueChanged<VaultItem> onEdit;

  const PinHealthSection({
    super.key,
    required this.items,
    required this.onEdit,
  });

  // Seuil symétrique du < 60 utilisé pour les mots de passe : frontière
  // medium/strong de PinScore (0-30 weak, 30-65 medium, 65+ strong).
  List<VaultItem> get _weak =>
      items.where((i) => PinScore.compute(i.pin) < 65).toList();

  List<List<VaultItem>> get _duplicateGroups {
    final map = <String, List<VaultItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.pin, () => []).add(item);
    }
    return map.values.where((g) => g.length > 1).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l           = AppLocalizations.of(context)!;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final accent      = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final weak        = _weak;
    final duplicates  = _duplicateGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          l.titlePinHealthSection,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accent),
        ),
        const SizedBox(height: 12),

        if (weak.isNotEmpty) ...[
          WeakPinsSection(items: weak, onEdit: onEdit),
          const SizedBox(height: 20),
        ],

        if (duplicates.isNotEmpty) ...[
          ReusedPinsSection(groups: duplicates, onEdit: onEdit),
          const SizedBox(height: 20),
        ],

        if (weak.isEmpty && duplicates.isEmpty) const HealthAllGoodPanel(),
      ],
    );
  }
}
