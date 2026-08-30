import 'package:flutter/material.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/utils/pin_score.dart';
import '../../../l10n/app_localizations.dart';

class PinHealthItemTile extends StatelessWidget {
  final VaultItem    item;
  final VoidCallback onEdit;

  const PinHealthItemTile({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s      = PinScore.compute(item.pin);

    return ListTile(
      dense:   true,
      leading: Icon(
        Icons.pin_outlined,
        color: PinScore.color(s),
        size:  22,
      ),
      title: Text(
        item.label,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        PinScore.label(s),
        style: TextStyle(color: PinScore.color(s), fontSize: 12),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.edit_outlined,
          color: isDark ? Colors.cyanAccent : Colors.blueAccent,
          size:  18,
        ),
        tooltip:   l.tooltipEdit,
        onPressed: onEdit,
      ),
    );
  }
}
