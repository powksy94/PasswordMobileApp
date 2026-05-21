import 'package:flutter/material.dart';
import '../../widgets/common/glass_panel.dart';
import '../../widgets/common/neon_text.dart';
import '../../widgets/auth/password_section.dart';
import '../../services/auth_service.dart';
import '../../utils/api_error.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey              = GlobalKey<FormState>();
  final _emailCtrl            = TextEditingController();
  final _passwordCtrl         = TextEditingController();
  final _confirmPasswordCtrl  = TextEditingController();
  final _masterPwCtrl         = TextEditingController();
  final _confirmMasterPwCtrl  = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _masterPwCtrl.dispose();
    _confirmMasterPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _masterPwCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final fill   = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GlassPanel(
            width:   350,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeonText(
                    text: 'Créer un compte', fontSize: 26, color: accent, glow: true),
                  const SizedBox(height: 12),

                  // Explication onboarding
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: accent),
                            const SizedBox(width: 6),
                            Text(
                              'Deux mots de passe distincts',
                              style: TextStyle(
                                color:      accent,
                                fontSize:   13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🔐  Mot de passe de connexion — vérifié par le serveur.\n'
                          '🗝️  Mot de passe maître — chiffre votre coffre localement. '
                          'Impossible à récupérer s\'il est perdu.',
                          style: TextStyle(
                            fontSize: 12,
                            color:    isDark ? Colors.white70 : Colors.black87,
                            height:   1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller:   _emailCtrl,
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

                  // Mot de passe de connexion
                  PasswordSection(
                    label:             'Mot de passe de connexion',
                    controller:        _passwordCtrl,
                    confirmController: _confirmPasswordCtrl,
                    minLength:         6,
                    confirmValidator:  (v) => v == _passwordCtrl.text
                        ? null
                        : 'Les mots de passe ne correspondent pas',
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe maître
                  PasswordSection(
                    label:             'Mot de passe maître (chiffre votre coffre)',
                    controller:        _masterPwCtrl,
                    confirmController: _confirmMasterPwCtrl,
                    minLength:         8,
                    showToggle:        true,
                    withInfoIcon:      true,
                    warningText:       'Ne peut pas être récupéré si oublié — notez-le.',
                    confirmValidator:  (v) => v == _masterPwCtrl.text
                        ? null
                        : 'Les mots de passe maîtres ne correspondent pas',
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Créer le compte'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
