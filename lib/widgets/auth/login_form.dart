import 'package:flutter/material.dart';
import '../common/glass_panel.dart';
import '../common/neon_text.dart';

/// Formulaire de connexion — étape 1 (email + mot de passe de connexion).
/// Le mot de passe maître est demandé dans une dialog séparée après succès.
class LoginForm extends StatelessWidget {
  final GlobalKey<FormState>   formKey;
  final TextEditingController  emailCtrl;
  final TextEditingController  passwordCtrl;
  final bool                   loading;
  final VoidCallback           onSubmit;
  final VoidCallback           onSignup;
  final Animation<double>      rotationAnimation;
  final bool                   showBiometric;
  final VoidCallback?          onBiometricTap;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.loading,
    required this.onSubmit,
    required this.onSignup,
    required this.rotationAnimation,
    this.showBiometric  = false,
    this.onBiometricTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final accent     = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final fill       = isDark ? Colors.white10 : Colors.black12;
    final panelWidth = (MediaQuery.sizeOf(context).width - 48).clamp(260.0, 350.0);

    return GlassPanel(
      width:   panelWidth,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(text: 'Connexion', fontSize: 26, color: accent, glow: true),
            const SizedBox(height: 16),

            // ── Biométrie ────────────────────────────────────────────────
            if (showBiometric) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onBiometricTap,
                  icon:  Icon(Icons.fingerprint, color: accent, size: 22),
                  label: Text(
                    'Se connecter avec l\'empreinte',
                    style: TextStyle(color: accent, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:    BorderSide(color: accent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color:    isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── Email ────────────────────────────────────────────────────
            TextFormField(
              controller:   emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Email invalide',
              decoration: InputDecoration(
                labelText:  'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled:     true,
                fillColor:  fill,
              ),
            ),
            const SizedBox(height: 10),

            // ── Mot de passe de connexion ────────────────────────────────
            TextFormField(
              controller:  passwordCtrl,
              obscureText: true,
              validator: (v) => v != null && v.length >= 6
                  ? null
                  : '6 caractères minimum',
              decoration: InputDecoration(
                labelText:  'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                filled:     true,
                fillColor:  fill,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: 10),

            RotationTransition(
              turns: rotationAnimation,
              child: const Icon(Icons.lock, size: 32, color: Colors.amberAccent),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: onSignup,
              child: Text(
                'Créer un compte',
                style: TextStyle(color: accent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
