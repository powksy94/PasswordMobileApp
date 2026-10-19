import 'dart:typed_data';
import '../../settings/services/settings_service.dart';
import './auth_service.dart';
import './biometric_service.dart';
import './biometric_unlock_service.dart';
import './master_password_verifier.dart';

/// Login with email + password + fingerprint: after the server login, gets
/// the vault key back from the biometric copy left on this device (session
/// expired, master password forgotten...) instead of asking for the master
/// password again. Only for the account this device was last used with.
class BiometricReloginService {
  /// The vault key and the vault payload fetched to verify it, or `null`
  /// when the caller must fall back to the master password (biometrics not
  /// set up, other account, prompt cancelled, key not matching the vault).
  static Future<({Uint8List key, List<dynamic>? raw})?> tryUnlock({
    required String email,
    required String token,
    required String promptTitle,
    required String cancelLabel,
  }) async {
    if (!await SettingsService.getBiometricEnabled()) return null;
    if (!await BiometricUnlockService.isProvisioned()) return null;
    if (!await BiometricService.isAvailable()) return null;

    final deviceEmail = await AuthService.getEmail();
    if (deviceEmail == null || _normalize(deviceEmail) != _normalize(email)) return null;

    final key = await BiometricUnlockService.unlock(
      promptTitle: promptTitle,
      cancelLabel: cancelLabel,
    );
    if (key == null) return null;

    // Master password changed from another device: this copy is stale.
    final result = await MasterPasswordVerifier.checkKeyAgainstServerVault(token: token, key: key);
    if (result.check == MasterPasswordCheck.mismatch) {
      await BiometricUnlockService.disable();
      return null;
    }
    return (key: key, raw: result.raw);
  }

  static String _normalize(String email) => email.trim().toLowerCase();
}
