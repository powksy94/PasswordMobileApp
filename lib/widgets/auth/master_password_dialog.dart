import 'package:flutter/material.dart';

/// Dialog demandant le mot de passe maître du coffre.
/// Retourne le mot de passe saisi ou null si annulé.
Future<String?> showMasterPasswordDialog(BuildContext context) async {
  final ctrl  = TextEditingController();
  bool  showPw = false;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: const Text('Mot de passe maître'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez votre mot de passe maître pour déchiffrer votre coffre.',
              style: TextStyle(
                color:    isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:  ctrl,
              obscureText: !showPw,
              autofocus:   true,
              decoration: InputDecoration(
                labelText:  'Mot de passe maître',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                filled:     true,
                fillColor:  isDark ? Colors.white10 : Colors.black12,
                suffixIcon: IconButton(
                  icon: Icon(showPw ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setS(() => showPw = !showPw),
                ),
              ),
              onSubmitted: (_) => Navigator.pop(ctx, ctrl.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce mot de passe est différent de votre mot de passe de connexion.',
              style: TextStyle(
                color:    accent.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Déverrouiller le coffre'),
          ),
        ],
      ),
    ),
  );
}
