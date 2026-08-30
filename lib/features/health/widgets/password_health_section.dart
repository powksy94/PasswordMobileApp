import 'package:flutter/material.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/utils/password_score.dart';
import './health_score_card.dart';
import './weak_passwords_section.dart';
import './reused_passwords_section.dart';
import './health_all_good_panel.dart';

/// Section "Santé des mots de passe" : analyse (score global, faibles,
/// réutilisés) et rendu, entièrement autonome à partir des items mot de
/// passe fournis par la page.
class PasswordHealthSection extends StatelessWidget {
  final List<VaultItem>         items;
  final ValueChanged<VaultItem> onEdit;

  const PasswordHealthSection({
    super.key,
    required this.items,
    required this.onEdit,
  });

  List<VaultItem> get _weak =>
      items.where((i) => PasswordScore.compute(i.password) < 60).toList();

  List<List<VaultItem>> get _duplicateGroups {
    final map = <String, List<VaultItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.password, () => []).add(item);
    }
    return map.values.where((g) => g.length > 1).toList();
  }

  int get _globalScore {
    if (items.isEmpty) return 100;
    return (items
            .map((i) => PasswordScore.compute(i.password))
            .fold(0, (a, b) => a + b) /
        items.length)
        .round();
  }

  @override
  Widget build(BuildContext context) {
    final weak       = _weak;
    final duplicates = _duplicateGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HealthScoreCard(
          score:       _globalScore,
          total:       items.length,
          strongCount: items.where((i) => PasswordScore.compute(i.password) >= 80).length,
          weakCount:   weak.length,
          dupCount:    duplicates.fold(0, (s, g) => s + g.length),
        ),

        if (weak.isNotEmpty) ...[
          const SizedBox(height: 20),
          WeakPasswordsSection(items: weak, onEdit: onEdit),
        ],

        if (duplicates.isNotEmpty) ...[
          const SizedBox(height: 20),
          ReusedPasswordsSection(groups: duplicates, onEdit: onEdit),
        ],

        if (weak.isEmpty && duplicates.isEmpty) ...[
          const SizedBox(height: 20),
          const HealthAllGoodPanel(),
        ],
      ],
    );
  }
}
