import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_password_service.dart';
import '../../services/auth_service.dart';
import '../../services/role_provider.dart';
import '../../widgets/auth/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey             = GlobalKey<FormState>();
  final _emailCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _masterPasswordCtrl  = TextEditingController();
  final _adminPasswordCtrl   = TextEditingController();
  final _teamAdminPasswordCtrl = TextEditingController();

  bool _loading      = false;
  bool _showMasterPw = false;

  late AnimationController _lockController;
  late Animation<double>   _rotationAnimation;

  int    _tapCountAdmin = 0;
  Timer? _tapResetTimerAdmin;
  int    _tapCountTeam  = 0;
  Timer? _tapResetTimerTeam;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _masterPasswordCtrl.dispose();
    _adminPasswordCtrl.dispose();
    _teamAdminPasswordCtrl.dispose();
    _lockController.dispose();
    _tapResetTimerAdmin?.cancel();
    _tapResetTimerTeam?.cancel();
    super.dispose();
  }

  // ── Login utilisateur ─────────────────────────────────────────────────────

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    try {
      await AuthService.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _masterPasswordCtrl.text,
      );
      if (!mounted) return;

      final roleStr = await AuthService.getUserRoleString();
      if (!mounted) return;

      switch (roleStr) {
        case 'admin':
          roleProvider.setRole(UserRole.admin);
        case 'team_admin':
          roleProvider.setRole(UserRole.teamAdmin);
        default:
          break;
      }
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        _snack('Erreur de connexion : $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Login admin local ─────────────────────────────────────────────────────

  Future<void> _submitAdminPassword() async {
    final input = _adminPasswordCtrl.text.trim();
    if (input.isEmpty) { _snack('Veuillez saisir un mot de passe admin'); return; }
    setState(() => _loading = true);

    final hasPassword = await AdminPasswordService.hasPassword();
    if (!hasPassword) {
      await AdminPasswordService.setPassword(input);
    } else {
      final correct = await AdminPasswordService.verifyPassword(input);
      if (!correct) {
        if (mounted) {
          _snack('Mot de passe admin incorrect');
          setState(() => _loading = false);
        }
        return;
      }
    }

    if (!mounted) return;
    Provider.of<RoleProvider>(context, listen: false).setRole(UserRole.admin);
    Navigator.pushReplacementNamed(context, '/home');
    setState(() => _loading = false);
  }

  // ── Login team admin ──────────────────────────────────────────────────────

  Future<void> _submitTeamAdminPassword() async {
    final input = _teamAdminPasswordCtrl.text.trim();
    if (input.isEmpty) { _snack('Veuillez saisir un mot de passe Team Admin'); return; }
    setState(() => _loading = true);
    try {
      final correct =
          await AdminPasswordService.verifyTeamAdminPassword(input);
      if (!mounted) return;
      if (!correct) { _snack('Mot de passe Team Admin incorrect'); return; }
      Provider.of<RoleProvider>(context, listen: false)
          .setRole(UserRole.teamAdmin);
      Navigator.pushReplacementNamed(context, '/home');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Dialogues secrets ─────────────────────────────────────────────────────

  void _showAdminDialog() {
    _adminPasswordCtrl.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title:   const Text('Admin Login'),
        content: TextField(
          controller:  _adminPasswordCtrl,
          obscureText: true,
          decoration:
              const InputDecoration(labelText: 'Mot de passe admin'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _submitAdminPassword(); },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showTeamAdminDialog() {
    _teamAdminPasswordCtrl.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title:   const Text('Team Admin Login'),
        content: TextField(
          controller:  _teamAdminPasswordCtrl,
          obscureText: true,
          decoration:
              const InputDecoration(labelText: 'Mot de passe Team Admin'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _submitTeamAdminPassword(); },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  // ── Tap zones secrètes ────────────────────────────────────────────────────

  void _handleSecretTapAdmin() {
    _tapCountAdmin++;
    _tapResetTimerAdmin?.cancel();
    _tapResetTimerAdmin =
        Timer(const Duration(seconds: 2), () => _tapCountAdmin = 0);
    if (_tapCountAdmin >= 5) {
      _tapCountAdmin = 0;
      _lockController.forward(from: 0);
      _showAdminDialog();
    }
  }

  Future<void> _handleSecretTapTeamAdmin() async {
    _tapCountTeam++;
    _tapResetTimerTeam?.cancel();
    _tapResetTimerTeam =
        Timer(const Duration(seconds: 2), () => _tapCountTeam = 0);
    if (_tapCountTeam >= 5) {
      _tapCountTeam = 0;
      final hasTeamPw = await AdminPasswordService.hasTeamAdminPassword();
      if (!mounted) return;
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
        _showTeamAdminDialog();
      }
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: LoginForm(
                formKey:           _formKey,
                emailCtrl:         _emailCtrl,
                passwordCtrl:      _passwordCtrl,
                masterPasswordCtrl: _masterPasswordCtrl,
                loading:           _loading,
                showMasterPw:      _showMasterPw,
                onToggleMasterPw:  () =>
                    setState(() => _showMasterPw = !_showMasterPw),
                onSubmit:          _submitUser,
                onSignup:          () => Navigator.pushNamed(context, '/signup'),
                rotationAnimation: _rotationAnimation,
              ),
            ),
          ),
          Positioned(
            top: 20, right: 20,
            child: GestureDetector(
              onTap: _handleSecretTapAdmin,
              child: const Icon(Icons.admin_panel_settings, size: 30),
            ),
          ),
          Positioned(
            top: 20, left: 20,
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
