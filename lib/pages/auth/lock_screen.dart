import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/fcm_service.dart';
import '../../widgets/auth/lock_screen_panel.dart';
import '../../l10n/app_localizations.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordCtrl = TextEditingController();
  bool _loading            = false;
  bool _showPassword       = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    final available = await BiometricService.isAvailable();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
    if (available) _unlockBiometric();
  }

  Future<void> _unlockBiometric() async {
    final authenticated = await BiometricService.authenticate();
    if (!authenticated || !mounted) return;

    final success = await AuthService.unlockFromStorage();
    if (!mounted) return;

    if (success) {
      FcmService.initialize();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorBiometricKey)),
      );
    }
  }

  Future<void> _unlockPassword() async {
    if (_passwordCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    final success =
        await AuthService.unlockWithMasterPassword(_passwordCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      FcmService.initialize();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _passwordCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorWrongMasterPassword)),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: LockScreenPanel(
                  biometricAvailable: _biometricAvailable,
                  passwordCtrl:       _passwordCtrl,
                  showPassword:       _showPassword,
                  loading:            _loading,
                  onBiometric:        _unlockBiometric,
                  onUnlock:           _unlockPassword,
                  onTogglePassword:   () => setState(() => _showPassword = !_showPassword),
                  onLogout:           _logout,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
