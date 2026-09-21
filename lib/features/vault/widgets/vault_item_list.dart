import 'package:flutter/material.dart';
import '../models/vault_item.dart';
import '../../../shared/widgets/common/neon_text.dart';
import './vault_item_card.dart';
import '../../../l10n/app_localizations.dart';

/// Vault item list (or empty state), extracted from [VaultPage]: pure
/// rendering, no state logic of its own: everything is driven by the callbacks
/// and by the state (showPassword) that the page keeps carrying.
class VaultItemList extends StatelessWidget {
  final List<VaultItem>            items;
  final bool                       hasSearchQuery;
  final Map<String, bool>          showPassword;
  final void Function(String id)                   onTogglePassword;
  final void Function(String text, String label)   onCopy;
  final void Function(VaultItem item)               onEdit;
  final void Function(String id)                    onDelete;

  const VaultItemList({
    super.key,
    required this.items,
    required this.hasSearchQuery,
    required this.showPassword,
    required this.onTogglePassword,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    if (items.isEmpty) {
      return Center(
        child: NeonText(
          text:     hasSearchQuery ? l.vaultNoResults : l.vaultEmpty,
          fontSize: 20,
          color:    accent,
          glow:     true,
        ),
      );
    }

    return ListView.builder(
      padding:     const EdgeInsets.all(16),
      itemCount:   items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return VaultItemCard(
          item:             item,
          showPassword:     showPassword[item.id] ?? false,
          onTogglePassword: () => onTogglePassword(item.id),
          onCopy:   onCopy,
          onEdit:   () => onEdit(item),
          onDelete: () => onDelete(item.id),
        );
      },
    );
  }
}
