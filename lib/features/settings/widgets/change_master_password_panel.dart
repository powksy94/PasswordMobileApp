import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

class ChangeMasterPasswordPanel extends StatelessWidget {
  final TextEditingController currentCtrl;
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;
  final bool fieldsEnabled;
  final bool loading;
  final VoidCallback onSubmit;

  const ChangeMasterPasswordPanel({
    super.key,
    required this.currentCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.fieldsEnabled,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final accent = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.blueAccent;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.titleChangeMasterPassword,
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
            enabled: fieldsEnabled,
            decoration: InputDecoration(
              labelText:  l.labelCurrentMasterPassword,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  newCtrl,
            obscureText: true,
            enabled: fieldsEnabled,
            decoration: InputDecoration(
              labelText:  l.labelNewMasterPassword,
              prefixIcon: const Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  confirmCtrl,
            obscureText: true,
            enabled: fieldsEnabled,
            decoration: InputDecoration(
              labelText:  l.labelConfirmNewMasterPassword,
              prefixIcon: const Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 16),
          if (loading) ...[
            Row(
              children: [
                const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(l.progressReencrypting),
              ],
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: fieldsEnabled && !loading ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
              child: Text(l.btnChangeMasterPassword),
            ),
          ),
        ],
      ),
    );
  }
}
