import 'package:flutter/material.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/password_strength_bar.dart';
import '../../widgets/neon_text.dart';
import '../../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService.register(email.text, password.text, password.text);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !')),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: GlassPanel(
          width: 350,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeonText(
                  text: "Créer un compte",
                  fontSize: 28,
                  color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                  glow: true,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: email,
                  validator: (v) => v != null && v.contains("@") ? null : "Email invalide",
                  decoration: const InputDecoration(labelText: "Email", filled: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v != null && v.length >= 6 ? null : "6 caractères minimum",
                  decoration: const InputDecoration(labelText: "Mot de passe", filled: true),
                ),
                const SizedBox(height: 8),
                PasswordStrengthBar(password: password.text),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassword,
                  obscureText: true,
                  validator: (v) => v == password.text ? null : "Les mots de passe ne correspondent pas",
                  decoration: const InputDecoration(labelText: "Confirmer le mot de passe", filled: true),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : submit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text("Créer le compte"),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                  child: const Text("Déjà un compte ? Se connecter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
