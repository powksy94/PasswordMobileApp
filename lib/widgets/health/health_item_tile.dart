import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_service.dart';
import '../../utils/password_score.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s      = PasswordScore.compute(item.password);

    return ListTile(
      dense:   true,
      leading: Icon(
        VaultService.getVaultIcon(item.icon),
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
        tooltip:   'Modifier',
        onPressed: onEdit,
      ),
    );
  }
}
