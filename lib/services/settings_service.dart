import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyLockTimeout = 'lock_timeout_minutes';

  // -1 = jamais
  static const int defaultTimeout = 5;

  static const List<int> timeoutOptions = [-1, 1, 5, 15, 30, 60];

  static Future<int> getLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLockTimeout) ?? defaultTimeout;
  }

  static Future<void> setLockTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLockTimeout, minutes);
  }

  static Duration? toDuration(int minutes) {
    if (minutes == -1) return null;
    return Duration(minutes: minutes);
  }

  // ── Confidentialité ───────────────────────────────────────────────────────

  static const _keyClipboardClearSeconds = 'clipboard_clear_seconds';
  static const int defaultClipboardClearSeconds = 30;
  static const List<int> clipboardClearOptions = [10, 30, 60, 120];

  static Future<int> getClipboardClearSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyClipboardClearSeconds) ?? defaultClipboardClearSeconds;
  }

  static Future<void> setClipboardClearSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyClipboardClearSeconds, seconds);
  }

  static const _keyBiometricEnabled = 'biometric_enabled';

  static Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? true;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  static const _keyMaskInBackground = 'mask_in_background';

  static Future<bool> getMaskInBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMaskInBackground) ?? true;
  }

  static Future<void> setMaskInBackground(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaskInBackground, enabled);
  }
}
