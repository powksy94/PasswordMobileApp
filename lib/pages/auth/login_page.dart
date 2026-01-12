import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/neon_text.dart';
import '../../services/admin_provider.dart';
import '../../services/role_manager.dart';
import '../../services/team_admin_provider.dart';
import '../../services/admin_password_service.dart';
import 'package:password_mobile_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final adminPasswordController = TextEditingController();
  final teamAdminPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _loading = false;

  late AnimationController _lockController;
  late Animation<double> _rotationAnimation;

  int _tapCountAdmin = 0;
  Timer? _tapResetTimerAdmin;

  int _tapCountTeam = 0;
  Timer? _tapResetTimerTeam;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    adminPasswordController.dispose();
    teamAdminPasswordController.dispose();
    _lockController.dispose();
    _tapResetTimerAdmin?.cancel();
    _tapResetTimerTeam?.cancel();
    super.dispose();
  }

  /// Login normal
  void submitUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulation login
      await AuthService.login(emailController.text.trim());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur utilisateur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Login admin
  void submitAdminPassword() async {
    final input = adminPasswordController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un mot de passe admin')),
      );
      return;
    }

    setState(() => _loading = true);

    final existingPassword = await AdminPasswordService.getPassword();

    if (existingPassword != null && input != existingPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe admin incorrect')),
      );
      setState(() => _loading = false);
      return;
    }

    if (existingPassword == null) {
      await AdminPasswordService.setPassword(input);
    }

    Provider.of<AdminProvider>(context, listen: false).activateAdmin();
    Provider.of<RoleManager>(context, listen: false).setRole(UserRole.admin);

    await AuthService.login("admin@local");

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');

    setState(() => _loading = false);
  }

  /// Login team admin
  void submitTeamAdminPassword() async {
    final input = teamAdminPasswordController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un mot de passe Team Admin')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final correct = await AdminPasswordService.verifyTeamAdminPassword(input);

      if (!correct) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe Team Admin incorrect')),
        );
        return;
      }

      Provider.of<TeamAdminProvider>(context, listen: false).setTeamAdmin(true);
      Provider.of<RoleManager>(context, listen: false).setRole(UserRole.teamAdmin);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void showAdminDialog() {
    adminPasswordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Admin Login"),
        content: TextField(
          controller: adminPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Mot de passe admin"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: submitAdminPassword,
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  void showTeamAdminDialog() {
    teamAdminPasswordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Team Admin Login"),
        content: TextField(
          controller: teamAdminPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Mot de passe Team Admin"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: submitTeamAdminPassword,
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  void _handleSecretTapAdmin() {
    _tapCountAdmin++;
    _tapResetTimerAdmin?.cancel();
    _tapResetTimerAdmin = Timer(const Duration(seconds: 2), () => _tapCountAdmin = 0);

    if (_tapCountAdmin >= 5) {
      _tapCountAdmin = 0;
      _lockController.forward(from: 0);
      showAdminDialog();
    }
  }

  void _handleSecretTapTeamAdmin() {
    _tapCountTeam++;
    _tapResetTimerTeam?.cancel();
    _tapResetTimerTeam = Timer(const Duration(seconds: 2), () => _tapCountTeam = 0);

    if (_tapCountTeam >= 5) {
      _tapCountTeam = 0;
      showTeamAdminDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: GlassPanel(
              width: 350,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeonText(
                      text: "Connexion",
                      fontSize: 28,
                      color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                      glow: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      validator: (v) => v != null && v.contains("@") ? null : "Email invalide",
                      decoration: InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      validator: (v) => v != null && v.length >= 6 ? null : "6 caractères minimum",
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : submitUser,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Se connecter"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(Icons.lock, size: 40, color: Colors.amberAccent),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, "/signup"),
                      child: Text(
                        "Créer un compte",
                        style: TextStyle(
                            color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Accès admin caché
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: _handleSecretTapAdmin,
              child: const Icon(Icons.admin_panel_settings, size: 30),
            ),
          ),

          /// Accès team admin caché
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: _handleSecretTapTeamAdmin,
              child: const Icon(Icons.group, size: 30, color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}
