import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../../settings/services/settings_service.dart';
import '../../notifications/services/fcm_service.dart';
import '../../../shared/services/role_provider.dart';
import '../utils/api_error.dart';
import '../widgets/login_form.dart';
import '../widgets/master_password_dialog.dart';
import '../../../shared/services/ad_service.dart';
import '../../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading       = false;
  bool _showBiometric = false;

  late AnimationController _lockController;
  late Animation<double>   _rotationAnimation;

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
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _lockController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final enabled      = await SettingsService.getBiometricEnabled();
    final hasSession   = await AuthService.hasLoggedOutSession();
    final bioAvailable = enabled && hasSession && await BiometricService.isAvailable();
    if (mounted) setState(() => _showBiometric = bioAvailable);
  }

  Future<void> _loginWithBiometric() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _loading = true);

    final authenticated = await BiometricService.authenticate(
      reason: l.biometricReason,
    );
    if (!mounted) return;

    if (!authenticated) {
      setState(() => _loading = false);
      _snack(l.errorBiometricFailed);
      return;
    }

    final success = await AuthService.restoreSessionAfterBiometric();
    if (!mounted) return;
    setState(() => _loading = false);

    if (!success) {
      _snack(l.sessionExpired);
      setState(() => _showBiometric = false);
      return;
    }

    if (!mounted) return;
    final roleStr = await AuthService.getUserRoleString();
    if (!mounted) return;
    _applyRole(roleStr);
    FcmService.initialize();
    await AdService.load();
    await AdService.showIfReady();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final session = await AuthService.loginToServer(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!mounted) return;
      setState(() => _loading = false);

      final masterPw = await showMasterPasswordDialog(context);
      if (masterPw == null || masterPw.isEmpty || !mounted) return;

      setState(() => _loading = true);
      await AuthService.completeLogin(
        token:          session.token,
        role:           session.role,
        salt:           session.salt,
        masterPassword: masterPw,
        email:          _emailCtrl.text.trim(),
      );
      if (!mounted) return;

      final roleStr = await AuthService.getUserRoleString();
      if (!mounted) return;
      _applyRole(roleStr);
      FcmService.initialize();
      await AdService.load();
      await AdService.showIfReady();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _snack(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyRole(String roleStr) {
    final rp = Provider.of<RoleProvider>(context, listen: false);
    switch (roleStr) {
      case 'admin':      rp.setRole(UserRole.admin);
      case 'team_admin': rp.setRole(UserRole.teamAdmin);
      default:           break;
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: LoginForm(
            formKey:           _formKey,
            emailCtrl:         _emailCtrl,
            passwordCtrl:      _passwordCtrl,
            loading:           _loading,
            onSubmit:          _submitUser,
            onSignup:          () => Navigator.pushNamed(context, '/signup'),
            rotationAnimation: _rotationAnimation,
            showBiometric:     _showBiometric,
            onBiometricTap:    _loginWithBiometric,
          ),
        ),
      ),
    );
  }
}
