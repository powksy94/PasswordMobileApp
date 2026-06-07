import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

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
            l.titleChangePassword,
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
            decoration: InputDecoration(
              labelText:  l.labelCurrentPassword,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  newCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText:  l.labelNewPassword,
              prefixIcon: const Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  confirmCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText:  l.labelConfirmNewPassword,
              prefixIcon: const Icon(Icons.lock_reset),
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
                  : Text(l.btnChangePassword),
            ),
          ),
        ],
      ),
    );
  }
}
