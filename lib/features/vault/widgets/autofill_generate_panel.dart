import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../l10n/app_localizations.dart';

/// Presentation for [AutofillGeneratePage]: the same unlock controls as
/// [LockScreenPanel], minus logout (meaningless in this context) and with a
/// cancel action instead - declining here just means "no suggestion", not
/// signing out of anything.
class AutofillGeneratePanel extends StatelessWidget {
  final bool                  biometricAvailable;
  final TextEditingController passwordCtrl;
  final bool                  showPassword;
  final bool                  loading;
  final VoidCallback          onBiometric;
  final VoidCallback          onUnlock;
  final VoidCallback          onTogglePassword;
  final VoidCallback          onCancel;

  const AutofillGeneratePanel({
    super.key,
    required this.biometricAvailable,
    required this.passwordCtrl,
    required this.showPassword,
    required this.loading,
    required this.onBiometric,
    required this.onUnlock,
    required this.onTogglePassword,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final l      = AppLocalizations.of(context)!;

    final panelWidth = (MediaQuery.sizeOf(context).width - 48).clamp(260.0, 340.0);

    return GlassPanel(
      width:   panelWidth,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/password-mobile-app-logo.png',
            width:  80,
            height: 80,
          ),
          const SizedBox(height: 16),
          NeonText(text: l.autofillGenerateTitle, fontSize: 22, color: accent, glow: true),
          const SizedBox(height: 8),
          Text(
            l.autofillGenerateSubtitle,
            style: TextStyle(
              color:    isDark ? Colors.white54 : Colors.black45,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (biometricAvailable) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onBiometric,
                icon:  Icon(Icons.fingerprint, color: accent),
                label: Text(l.biometricUnlock, style: TextStyle(color: accent)),
                style: OutlinedButton.styleFrom(
                  side:    BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.lockScreenOrPassword,
              style: TextStyle(
                color:    isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller:  passwordCtrl,
            obscureText: !showPassword,
            onSubmitted: (_) => onUnlock(),
            decoration: InputDecoration(
              labelText:  l.labelMasterPassword,
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              suffixIcon: IconButton(
                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: onTogglePassword,
              ),
              filled:    true,
              fillColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onUnlock,
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width:  18,
                      child:  CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.btnUnlock),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onCancel,
            child: Text(
              l.btnCancel,
              style: TextStyle(
                color:    isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
