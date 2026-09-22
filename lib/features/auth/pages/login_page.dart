import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/biometric_unlock_service.dart';
import '../services/master_key_service.dart';
import '../services/master_password_verifier.dart';
import '../../vault/services/vault_service.dart';
import '../../settings/services/settings_service.dart';
import '../../notifications/services/fcm_service.dart';
import '../../../shared/services/role_provider.dart';
import '../../../shared/utils/api_error.dart';
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
    final bioAvailable = enabled &&
        hasSession &&
        await BiometricService.isAvailable() &&
        await BiometricUnlockService.isProvisioned();
    if (mounted) setState(() => _showBiometric = bioAvailable);
  }

  Future<void> _loginWithBiometric() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _loading = true);

    final success = await AuthService.restoreSessionAfterBiometric(
      promptTitle: l.biometricReason,
      cancelLabel: l.btnCancel,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!success) {
      _snack(l.errorBiometricFailed);
      // Cancelled -> the button stays so the user can retry; key invalidated ->
      // `unlock()` disabled the store, the re-read then hides the button.
      await _checkBiometricAvailability();
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

      final masterPw = await _askVerifiedMasterPassword(
        token: session.token,
        salt:  session.salt,
      );
      if (masterPw == null || !mounted) return;

      setState(() => _loading = true);
      await AuthService.completeLogin(
        token:          session.token,
        role:           session.role,
        salt:           session.salt,
        masterPassword: masterPw,
        email:          _emailCtrl.text.trim(),
      );
      if (!mounted) return;

      final l = AppLocalizations.of(context)!;
      final key = MasterKeyService.getMasterKey();
      if (key != null) {
        await BiometricUnlockService.maybeAutoEnable(
          key,
          biometricEnabledSetting: await SettingsService.getBiometricEnabled(),
          promptTitle: l.biometricReason,
          cancelLabel: l.btnCancel,
        );
        if (!mounted) return;
      }

      final roleStr = await AuthService.getUserRoleString();
      if (!mounted) return;
      _applyRole(roleStr);
      FcmService.initialize();
      await AdService.load();
      await AdService.showIfReady();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _snack(apiErrorMessage(AppLocalizations.of(context)!, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Asks for the master password again until it matches the existing vault:
  /// a typo must never be persisted as the key.
  /// `null` if the user cancels.
  Future<String?> _askVerifiedMasterPassword({
    required String token,
    required String salt,
  }) async {
    while (mounted) {
      final masterPw = await showMasterPasswordDialog(context);
      if (masterPw == null || masterPw.isEmpty || !mounted) return null;

      setState(() => _loading = true);
      final result = await MasterPasswordVerifier.checkAgainstServerVault(
        token:          token,
        salt:           salt,
        masterPassword: masterPw,
      );
      if (!mounted) return null;
      setState(() => _loading = false);

      if (result.check != MasterPasswordCheck.mismatch) {
        // Spares VaultPage/PasswordHealthPage an immediate re-fetch of the
        // vault we just downloaded to verify the password.
        if (result.raw != null) VaultService.primeFromVerification(result.raw!);
        return masterPw;
      }
      _snack(AppLocalizations.of(context)!.errorWrongMasterPassword);
    }
    return null;
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
