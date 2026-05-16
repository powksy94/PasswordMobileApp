import 'package:flutter/material.dart';
import '../common/glass_panel.dart';
import '../common/neon_text.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState>      formKey;
  final TextEditingController     emailCtrl;
  final TextEditingController     passwordCtrl;
  final TextEditingController     masterPasswordCtrl;
  final bool                      loading;
  final bool                      showMasterPw;
  final VoidCallback              onToggleMasterPw;
  final VoidCallback              onSubmit;
  final VoidCallback              onSignup;
  final Animation<double>         rotationAnimation;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.masterPasswordCtrl,
    required this.loading,
    required this.showMasterPw,
    required this.onToggleMasterPw,
    required this.onSubmit,
    required this.onSignup,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final fill   = isDark ? Colors.white10 : Colors.black12;

    return GlassPanel(
      width:   350,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(text: 'Connexion', fontSize: 28, color: accent, glow: true),
            const SizedBox(height: 20),

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
            const SizedBox(height: 12),

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
            const SizedBox(height: 12),

            TextFormField(
              controller:  masterPasswordCtrl,
              obscureText: !showMasterPw,
              validator: (v) =>
                  v != null && v.isNotEmpty ? null : 'Requis',
              decoration: InputDecoration(
                labelText:      'Mot de passe maître (coffre)',
                prefixIcon:     const Icon(Icons.vpn_key_outlined),
                helperText:     'Chiffre votre coffre — différent du mot de passe de connexion',
                helperMaxLines: 2,
                filled:         true,
                fillColor:      fill,
                suffixIcon: IconButton(
                  icon: Icon(
                    showMasterPw ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleMasterPw,
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width:  18,
                        child:  CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: 12),

            RotationTransition(
              turns: rotationAnimation,
              child: const Icon(Icons.lock, size: 40, color: Colors.amberAccent),
            ),
            const SizedBox(height: 12),

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
