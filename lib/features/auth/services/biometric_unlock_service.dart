import 'dart:convert';
import 'dart:typed_data';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './biometric_service.dart';

/// Stores a copy of the master key in the Android Keystore / iOS Secure
/// Enclave (`biometric_storage`), so that the biometric unlock is
/// guaranteed by the hardware rather than by a mere app-level boolean
/// (see `upgrade/BIOMETRIC_UNLOCK_HARDENING.md`). Store distinct from the one
/// used by `biometric_export_service.dart` for the export.
///
/// Knows nothing about [MasterKeyService]: each caller provides the
/// key to protect and gets the unlocked one back.
class BiometricUnlockService {
  static const _storeName = 'vault_unlock_key_v1';

  // Tracking (without a prompt) of the provisioning state: avoids having to read
  // the store, which would trigger a prompt, just to know whether it
  // already contains something.
  static const _prefProvisioned = 'biometric_unlock_key_provisioned';

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Reads the key (triggers the hardware biometric prompt). `null` on
  /// cancellation, failure or missing/invalidated key: the caller must
  /// then offer the password unlock.
  static Future<Uint8List?> unlock({
    required String promptTitle,
    required String cancelLabel,
  }) async {
    try {
      final store  = await _storage();
      final stored = await store.read(promptInfo: _promptInfo(promptTitle, cancelLabel));
      if (stored == null) return null;
      return Uint8List.fromList(base64Decode(stored));
    } on AuthException catch (e) {
      if (e.code == AuthExceptionCode.userCanceled || e.code == AuthExceptionCode.canceled) {
        return null;
      }
      // Unexpected error (e.g. key invalidated after the fingerprints
      // enrolled on the device changed): we clean up to avoid failing
      // forever instead of offering a broken biometric again.
      await disable();
      return null;
    } catch (_) {
      await disable();
      return null;
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Writes [key] to the biometric-protected store (triggers a prompt).
  /// Returns `false` (without rethrowing) on cancellation or
  /// failure: enabling biometrics must never make the operation that
  /// triggered it fail (login, master password change...), which
  /// already succeeded at this point.
  static Future<bool> enable(
    Uint8List key, {
    required String promptTitle,
    required String cancelLabel,
  }) async {
    try {
      final store = await _storage();
      await store.write(
        base64Encode(key),
        promptInfo: _promptInfo(promptTitle, cancelLabel),
      );
      await _setProvisioned(true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes the key. No prompt (file deletion, no cryptographic operation
  /// on the native plugin side).
  static Future<void> disable() async {
    try {
      final store = await _storage();
      await store.delete();
    } catch (_) {
      // Nothing to delete or store never initialized: harmless.
    }
    await _setProvisioned(false);
  }

  // ── Call scenarios ─────────────────────────────────────────────────────────

  /// To call right after a successful login/signup, with the master
  /// key that was just derived. If biometrics are enabled (settings)
  /// and available, but never provisioned on this device yet,
  /// enables it: a single prompt, once, never repeated on later
  /// logins.
  static Future<void> maybeAutoEnable(
    Uint8List key, {
    required bool biometricEnabledSetting,
    required String promptTitle,
    required String cancelLabel,
  }) async {
    if (!biometricEnabledSetting) return;
    if (await isProvisioned()) return;
    if (!await BiometricService.isAvailable()) return;
    await enable(key, promptTitle: promptTitle, cancelLabel: cancelLabel);
  }

  /// To call after a master password change / vault reset,
  /// with the new key: if biometrics were already provisioned, it
  /// updates them (otherwise the old copy would still encrypt the old
  /// key). Does nothing if it was not enabled: no surprise prompt.
  ///
  /// If the user cancels this prompt, we disable instead of leaving
  /// a now-stale key in the store: a future biometric unlock
  /// would read it "successfully" but return the OLD key,
  /// silently corrupting the vault decryption instead of simply
  /// falling back to the password.
  static Future<void> resyncAfterKeyChange(
    Uint8List key, {
    required String promptTitle,
    required String cancelLabel,
  }) async {
    if (!await isProvisioned()) return;
    final success = await enable(key, promptTitle: promptTitle, cancelLabel: cancelLabel);
    if (!success) await disable();
  }

  // ── State ──────────────────────────────────────────────────────────────────────

  static Future<bool> isProvisioned() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefProvisioned) ?? false;
  }

  static Future<void> _setProvisioned(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefProvisioned, value);
  }

  // ── Low level ────────────────────────────────────────────────────────────────

  static Future<BiometricStorageFile> _storage() {
    return BiometricStorage().getStorage(
      _storeName,
      options: StorageFileInitOptions(
        authenticationRequired: true,
        // -1 = always ask for biometrics again, no validity window.
        authenticationValidityDurationSeconds: -1,
        androidBiometricOnly: true,
      ),
    );
  }

  static PromptInfo _promptInfo(String title, String cancelLabel) => PromptInfo(
        androidPromptInfo: AndroidPromptInfo(title: title, negativeButton: cancelLabel),
        iosPromptInfo: IosPromptInfo(saveTitle: title, accessTitle: title),
      );
}
