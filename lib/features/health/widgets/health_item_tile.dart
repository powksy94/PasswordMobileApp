import 'package:flutter/material.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/utils/password_score.dart';
import '../../vault/utils/vault_icons.dart';
import '../../../l10n/app_localizations.dart';

class HealthItemTile extends StatelessWidget {
  final VaultItem    item;
  final VoidCallback onEdit;

  const HealthItemTile({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s      = PasswordScore.compute(item.password);

    return ListTile(
      dense:   true,
      leading: Icon(
        VaultIcons.forName(item.icon),
        color: PasswordScore.color(s),
        size:  22,
      ),
      title: Text(
        item.label,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        PasswordScore.label(s),
        style: TextStyle(color: PasswordScore.color(s), fontSize: 12),
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
