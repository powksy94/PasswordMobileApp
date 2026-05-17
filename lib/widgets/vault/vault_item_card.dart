import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_service.dart';
import '../common/glass_panel.dart';
import '../common/neon_text.dart';

class VaultItemCard extends StatelessWidget {
  final VaultItem item;
  final bool      showPassword;
  final VoidCallback                          onTogglePassword;
  final void Function(String text, String label) onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VaultItemCard({
    super.key,
    required this.item,
    required this.showPassword,
    required this.onTogglePassword,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final accent    = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final subColor  = isDark ? Colors.white54 : Colors.black45;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(VaultService.getVaultIcon(item.icon), color: accent, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: NeonText(
                    text:     item.label,
                    fontSize: 16,
                    color:    accent,
                    glow:     true,
                    bold:     true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _iconBtn(Icons.edit_outlined,  accent,           'Modifier',  onEdit),
                const SizedBox(width: 4),
                _iconBtn(Icons.delete_outline, Colors.redAccent, 'Supprimer', onDelete),
              ],
            ),

            if (item.login.isNotEmpty) ...[
              const SizedBox(height: 10),
              _fieldRow(
                icon:      Icons.person_outline,
                text:      item.login,
                textColor: textColor,
                subColor:  subColor,
                onCopy:    () => onCopy(item.login, 'Login'),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: subColor),
                const SizedBox(width: 6),
                Expanded(
                  child: SelectableText(
                    showPassword ? item.password : '●●●●●●●●',
                    style: TextStyle(
                      color:      textColor,
                      fontFamily: 'monospace',
                      fontSize:   14,
                    ),
                  ),
                ),
                _iconBtn(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  Colors.orangeAccent,
                  showPassword ? 'Masquer' : 'Afficher',
                  onTogglePassword,
                  size: 18,
                ),
                const SizedBox(width: 4),
                _iconBtn(
                  Icons.copy,
                  Colors.greenAccent,
                  'Copier le mot de passe',
                  () => onCopy(item.password, 'Mot de passe'),
                  size: 18,
                ),
              ],
            ),

            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.notes, style: TextStyle(color: subColor, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fieldRow({
    required IconData     icon,
    required String       text,
    required Color        textColor,
    required Color        subColor,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: subColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(color: textColor, fontSize: 14)),
        ),
        _iconBtn(Icons.copy, Colors.greenAccent, 'Copier', onCopy, size: 18),
      ],
    );
  }

  static Widget _iconBtn(
    IconData     icon,
    Color        color,
    String       tooltip,
    VoidCallback onPressed, {
    double size = 20,
  }) {
    return IconButton(
      icon:        Icon(icon, color: color, size: size),
      padding:     EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip:     tooltip,
      onPressed:   onPressed,
    );
  }
}
