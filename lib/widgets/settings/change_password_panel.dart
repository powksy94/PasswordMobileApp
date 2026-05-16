import 'package:flutter/material.dart';
import '../common/glass_panel.dart';

class ChangePasswordPanel extends StatelessWidget {
  final TextEditingController currentCtrl;
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;
  final bool        loading;
  final VoidCallback onSubmit;

  const ChangePasswordPanel({
    super.key,
    required this.currentCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.blueAccent;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Changer le mot de passe de connexion',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.bold,
              color:      accent,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller:  currentCtrl,
            obscureText: true,
            decoration:  const InputDecoration(
              labelText:  'Mot de passe actuel',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  newCtrl,
            obscureText: true,
            decoration:  const InputDecoration(
              labelText:  'Nouveau mot de passe',
              prefixIcon: Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  confirmCtrl,
            obscureText: true,
            decoration:  const InputDecoration(
              labelText:  'Confirmer le nouveau mot de passe',
              prefixIcon: Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              child: loading
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Modifier le mot de passe'),
            ),
          ),
        ],
      ),
    );
  }
}
