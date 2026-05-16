import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/role_provider.dart';
import '../../widgets/common/neon_text.dart';
import '../../widgets/settings/change_password_panel.dart';
import '../../widgets/settings/danger_zone_panel.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _changingPw = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      _snack('Les nouveaux mots de passe ne correspondent pas');
      return;
    }
    if (_newPwCtrl.text.length < 6) {
      _snack('Le nouveau mot de passe doit faire au moins 6 caractères');
      return;
    }
    setState(() => _changingPw = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');
      await ApiService().changePassword(
          token, _currentPwCtrl.text, _newPwCtrl.text);
      if (!mounted) return;
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      _snack('Mot de passe modifié avec succès');
    } catch (e) {
      if (mounted) _snack('Erreur : $e');
    } finally {
      if (mounted) setState(() => _changingPw = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible.\n\n'
          'Tous vos mots de passe chiffrés seront définitivement supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');
      await ApiService().deleteAccount(token);
      if (!mounted) return;
      await _logoutAndRedirect();
    } catch (e) {
      if (mounted) _snack('Erreur : $e');
    }
  }

  Future<void> _logoutAndRedirect() async {
    await AuthService.logout();
    if (!mounted) return;
    Provider.of<RoleProvider>(context, listen: false).deactivate();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(
            text: 'Paramètres du compte', fontSize: 20, color: accent, glow: true),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ChangePasswordPanel(
              currentCtrl: _currentPwCtrl,
              newCtrl:     _newPwCtrl,
              confirmCtrl: _confirmPwCtrl,
              loading:     _changingPw,
              onSubmit:    _changePassword,
            ),
            const SizedBox(height: 20),
            DangerZonePanel(onDelete: _deleteAccount),
          ],
        ),
      ),
    );
  }
}
