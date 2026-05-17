import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_password_service.dart';
import '../../services/role_provider.dart';

/// Gère la connexion locale Admin et Team Admin (accès secret via 5 taps).
///
/// Instancier une fois dans [LoginPage], passer [context] aux handlers.
/// Appeler [dispose] dans [State.dispose].
class LocalAdminLoginHandler {
  final AnimationController        lockController;
  final TextEditingController      adminCtrl;
  final TextEditingController      teamAdminCtrl;
  final void Function(bool)        setLoading;

  int    _tapAdmin  = 0;
  Timer? _timerAdmin;
  int    _tapTeam   = 0;
  Timer? _timerTeam;

  LocalAdminLoginHandler({
    required this.lockController,
    required this.adminCtrl,
    required this.teamAdminCtrl,
    required this.setLoading,
  });

  void dispose() {
    _timerAdmin?.cancel();
    _timerTeam?.cancel();
  }

  // ── Admin (5 taps haut-droite) ────────────────────────────────────────────

  void handleAdminTap(BuildContext context) {
    _tapAdmin++;
    _timerAdmin?.cancel();
    _timerAdmin = Timer(const Duration(seconds: 2), () => _tapAdmin = 0);
    if (_tapAdmin >= 5) {
      _tapAdmin = 0;
      lockController.forward(from: 0);
      _showAdminDialog(context);
    }
  }

  void _showAdminDialog(BuildContext context) {
    adminCtrl.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title:   const Text('Admin Login'),
        content: TextField(
          controller:  adminCtrl,
          obscureText: true,
          decoration:  const InputDecoration(labelText: 'Mot de passe admin'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitAdmin(context);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAdmin(BuildContext context) async {
    final input = adminCtrl.text.trim();
    if (input.isEmpty) {
      _snack(context, 'Veuillez saisir un mot de passe admin');
      return;
    }
    setLoading(true);

    final hasPassword = await AdminPasswordService.hasPassword();
    if (!hasPassword) {
      await AdminPasswordService.setPassword(input);
    } else {
      final correct = await AdminPasswordService.verifyPassword(input);
      if (!correct) {
        if (context.mounted) {
          _snack(context, 'Mot de passe admin incorrect');
          setLoading(false);
        }
        return;
      }
    }
    if (!context.mounted) return;
    Provider.of<RoleProvider>(context, listen: false).setRole(UserRole.admin);
    setLoading(false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  // ── Team Admin (5 taps haut-gauche) ──────────────────────────────────────

  Future<void> handleTeamAdminTap(BuildContext context) async {
    _tapTeam++;
    _timerTeam?.cancel();
    _timerTeam = Timer(const Duration(seconds: 2), () => _tapTeam = 0);
    if (_tapTeam < 5) return;
    _tapTeam = 0;

    final hasTeamPw = await AdminPasswordService.hasTeamAdminPassword();
    if (!context.mounted) return;

    if (!hasTeamPw) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:   const Text('Team Admin'),
          content: const Text(
            'Aucun mot de passe Team Admin n\'est défini.\n\n'
            'L\'administrateur doit d\'abord en créer un.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _showTeamAdminDialog(context);
    }
  }

  void _showTeamAdminDialog(BuildContext context) {
    teamAdminCtrl.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title:   const Text('Team Admin Login'),
        content: TextField(
          controller:  teamAdminCtrl,
          obscureText: true,
          decoration:
              const InputDecoration(labelText: 'Mot de passe Team Admin'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTeamAdmin(context);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTeamAdmin(BuildContext context) async {
    final input = teamAdminCtrl.text.trim();
    if (input.isEmpty) {
      _snack(context, 'Veuillez saisir un mot de passe Team Admin');
      return;
    }
    setLoading(true);
    try {
      final correct = await AdminPasswordService.verifyTeamAdminPassword(input);
      if (!context.mounted) return;
      if (!correct) {
        _snack(context, 'Mot de passe Team Admin incorrect');
        return;
      }
      Provider.of<RoleProvider>(context, listen: false)
          .setRole(UserRole.teamAdmin);
      Navigator.pushReplacementNamed(context, '/home');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
}
