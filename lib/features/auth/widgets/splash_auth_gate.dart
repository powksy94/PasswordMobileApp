import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/master_key_service.dart';
import '../services/biometric_service.dart';
import '../services/biometric_unlock_service.dart';
import '../../settings/services/settings_service.dart';
import '../../notifications/services/fcm_service.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

class SplashAuthGate extends StatefulWidget {
  const SplashAuthGate({super.key});

  @override
  State<SplashAuthGate> createState() => _SplashAuthGateState();
}

class _SplashAuthGateState extends State<SplashAuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Session active (token + pas de flag logged_out)
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      // Tente le déverrouillage biométrique immédiat, seulement si l'utilisateur
      // l'a activé dans les réglages (sinon on tombe sur l'écran de verrouillage).
      final biometricEnabled = await SettingsService.getBiometricEnabled();
      if (!mounted) return;
      final bioAvailable = biometricEnabled &&
          await BiometricService.isAvailable() &&
          await BiometricUnlockService.isProvisioned();
      if (!mounted) return;

      if (bioAvailable) {
        final l = AppLocalizations.of(context)!;
        final key = await BiometricUnlockService.unlock(
          promptTitle: l.biometricReason,
          cancelLabel: l.btnCancel,
        );
        if (!mounted) return;

        if (key != null) {
          MasterKeyService.setUnlockedKey(key);
          FcmService.initialize();
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
      }
      Navigator.pushReplacementNamed(context, '/lock');
      return;
    }

    // Session fermée (soft-logout) → biométrie possible depuis /login
    // Session inexistante → /login classique
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      body: Center(
        child: GlassPanel(
          width:        260,
          blur:         8,
          borderRadius: 16,
          child: Column(
            mainAxisSize:      MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/password-mobile-app-logo.png',
                width: 70, height: 70,
              ),
              const SizedBox(height: 12),
              Text(
                'Password App',
                style: TextStyle(
                  fontSize:   24,
                  fontWeight: FontWeight.bold,
                  color:      accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chargement…',
                style: TextStyle(
                  fontSize: 16,
                  color:    isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
