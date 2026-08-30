import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/master_key_service.dart';
import '../services/biometric_service.dart';
import '../services/biometric_unlock_service.dart';
import '../../settings/services/settings_service.dart';
import '../../notifications/services/fcm_service.dart';
import '../widgets/lock_screen_panel.dart';
import '../../../shared/widgets/common/gradient_background.dart';
import '../../../l10n/app_localizations.dart';

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
    final enabled   = await SettingsService.getBiometricEnabled();
    final available = enabled &&
        await BiometricService.isAvailable() &&
        await BiometricUnlockService.isProvisioned();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
    if (available) _unlockBiometric();
  }

  Future<void> _unlockBiometric() async {
    final l = AppLocalizations.of(context)!;
    final key = await BiometricUnlockService.unlock(
      promptTitle: l.biometricReason,
      cancelLabel: l.btnCancel,
    );
    if (key == null || !mounted) return; // annulé/échoué → reste sur l'écran, mot de passe en repli

    MasterKeyService.setUnlockedKey(key);
    FcmService.initialize();
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _unlockPassword() async {
    if (_passwordCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    final success =
        await MasterKeyService.unlockWithMasterPassword(_passwordCtrl.text);
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
    return Scaffold(
      body: GradientBackground(
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
