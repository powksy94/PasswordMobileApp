import 'package:flutter/material.dart';
import '../common/glass_panel.dart';

/// Affiche le mot de passe généré avec les boutons visibilité et copie.
/// La logique de toggle et de copie est déléguée aux callbacks.
class GeneratedPasswordDisplay extends StatelessWidget {
  final String       password;
  final bool         showPassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;

  const GeneratedPasswordDisplay({
    super.key,
    required this.password,
    required this.showPassword,
    required this.onToggleVisibility,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return GlassPanel(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              password.isEmpty
                  ? 'Mot de passe vide'
                  : (showPassword ? password : '●●●●●●●●'),
              style: TextStyle(fontSize: 20, color: accent),
            ),
          ),
          if (password.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.orangeAccent,
              ),
              onPressed: onToggleVisibility,
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.greenAccent),
              onPressed: onCopy,
            ),
          ],
        ],
      ),
    );
  }
}
