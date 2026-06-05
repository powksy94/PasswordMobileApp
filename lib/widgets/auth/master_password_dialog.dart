import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

Future<String?> showMasterPasswordDialog(BuildContext context) async {
  final ctrl   = TextEditingController();
  bool  showPw = false;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setS) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.titleMasterPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.masterPasswordDialogContent,
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
                  labelText:  l.labelMasterPassword,
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
                l.masterPasswordDialogHint,
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
              child: Text(l.btnCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: Text(l.btnUnlockVault),
            ),
          ],
        );
      },
    ),
  );
}
