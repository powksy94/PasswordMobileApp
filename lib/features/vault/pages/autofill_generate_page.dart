import 'package:flutter/material.dart';
import '../../auth/services/biometric_service.dart';
import '../../auth/services/biometric_unlock_service.dart';
import '../../auth/services/master_key_service.dart';
import '../../auth/services/unlock_throttle.dart';
import '../../generator/services/password_generator.dart';
import '../../settings/services/settings_service.dart';
import '../../../shared/services/autofill_bridge_service.dart';
import '../../../shared/widgets/common/gradient_background.dart';
import '../widgets/autofill_generate_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Shown instead of the normal splash/login/home flow when the app is
/// launched by VaultAutofillService to authenticate and generate a password
/// for a "new password" field in another app (see
/// upgrade/ANDROID_AUTOFILL_SUGGESTION.md). No navigation, no ads: a single
/// dedicated screen, closed by the native side once done.
class AutofillGeneratePage extends StatefulWidget {
  const AutofillGeneratePage({super.key});

  @override
  State<AutofillGeneratePage> createState() => _AutofillGeneratePageState();
}

class _AutofillGeneratePageState extends State<AutofillGeneratePage> {
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
    if (MasterKeyService.getMasterKey() != null) {
      // Vault already unlocked in this process (app was already open):
      // generate right away, no unlock UI needed at all.
      await _generateAndFinish();
      return;
    }
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
    if (key == null || !mounted) return; // cancelled/failed -> stay on the screen, password as fallback

    MasterKeyService.setUnlockedKey(key);
    UnlockThrottle.reset().ignore(); // biometrics prove the owner is present
    await _generateAndFinish();
  }

  Future<void> _unlockPassword() async {
    if (_passwordCtrl.text.isEmpty) return;

    final wait = await UnlockThrottle.remaining();
    if (!mounted) return;
    if (wait > Duration.zero) {
      _showLockedOut(wait);
      return;
    }

    setState(() => _loading = true);

    final success =
        await MasterKeyService.unlockWithMasterPassword(_passwordCtrl.text);
    if (!mounted) return;

    if (success) {
      await UnlockThrottle.reset();
      if (!mounted) return;
      await _generateAndFinish();
    } else {
      setState(() => _loading = false);
      _passwordCtrl.clear();
      final delay = await UnlockThrottle.recordFailure();
      if (!mounted) return;
      if (delay > Duration.zero) {
        _showLockedOut(delay);
      } else {
        _snack(AppLocalizations.of(context)!.errorWrongMasterPassword);
      }
    }
  }

  Future<void> _generateAndFinish() async {
    final password = PasswordGenerator.generate();
    await AutofillBridgeService.completeGenerate(password);
    // The native side finishes this Activity right after; nothing left to
    // show, the third-party app reclaims the screen.
  }

  void _cancel() => AutofillBridgeService.cancelGenerate().ignore();

  void _showLockedOut(Duration wait) {
    final seconds = (wait.inMilliseconds / 1000).ceil();
    _snack(AppLocalizations.of(context)!.errorUnlockLockedOut(seconds));
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) { if (didPop) _cancel(); },
      child: Scaffold(
        body: GradientBackground(
          child: Center(
            child: AutofillGeneratePanel(
              biometricAvailable: _biometricAvailable,
              passwordCtrl:       _passwordCtrl,
              showPassword:       _showPassword,
              loading:            _loading,
              onBiometric:        _unlockBiometric,
              onUnlock:           _unlockPassword,
              onTogglePassword:   () => setState(() => _showPassword = !_showPassword),
              onCancel:           _cancel,
            ),
          ),
        ),
      ),
    );
  }
}
