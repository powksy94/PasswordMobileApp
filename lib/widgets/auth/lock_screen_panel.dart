import 'package:flutter/material.dart';
import '../common/glass_panel.dart';
import '../common/neon_text.dart';

class LockScreenPanel extends StatelessWidget {
  final bool                  biometricAvailable;
  final TextEditingController passwordCtrl;
  final bool                  showPassword;
  final bool                  loading;
  final VoidCallback          onBiometric;
  final VoidCallback          onUnlock;
  final VoidCallback          onTogglePassword;
  final VoidCallback          onLogout;

  const LockScreenPanel({
    super.key,
    required this.biometricAvailable,
    required this.passwordCtrl,
    required this.showPassword,
    required this.loading,
    required this.onBiometric,
    required this.onUnlock,
    required this.onTogglePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return GlassPanel(
      width:   340,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 56, color: accent),
          const SizedBox(height: 16),
          NeonText(
            text: 'Vault verrouillé', fontSize: 24, color: accent, glow: true),
          const SizedBox(height: 8),
          Text(
            'Session expirée après inactivité.',
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
                label: Text(
                  'Déverrouiller avec biométrie',
                  style: TextStyle(color: accent),
                ),
                style: OutlinedButton.styleFrom(
                  side:    BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ou entrez votre mot de passe maître',
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
              labelText:  'Mot de passe maître',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
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
                  : const Text('Déverrouiller'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onLogout,
            child: Text(
              'Se déconnecter',
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
