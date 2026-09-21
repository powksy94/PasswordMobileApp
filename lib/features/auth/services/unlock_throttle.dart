import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Ralentit les tentatives répétées de mot de passe maître sur l'écran de
/// verrouillage : les [freeAttempts] premières erreurs sont sans délai, puis
/// chaque erreur supplémentaire double l'attente ([baseDelay], plafonnée à
/// [maxDelay]). L'état est persisté pour qu'un simple redémarrage de
/// l'application ne remette pas le compteur à zéro.
class UnlockThrottle {
  static const freeAttempts = 5;
  static const baseDelay    = Duration(seconds: 30);
  static const maxDelay     = Duration(minutes: 15);

  static const _prefFailures    = 'unlock_failed_attempts';
  static const _prefLockedUntil = 'unlock_locked_until_ms';

  /// Attente imposée après [failures] erreurs consécutives.
  static Duration delayForFailures(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final doublings = min(failures - freeAttempts, 5);
    final delay = baseDelay * pow(2, doublings).toInt();
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Temps restant avant la prochaine tentative autorisée (zéro = libre).
  static Future<Duration> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_prefLockedUntil);
    if (until == null) return Duration.zero;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    return left > 0 ? Duration(milliseconds: left) : Duration.zero;
  }

  /// Enregistre une erreur et retourne l'attente qui en découle.
  static Future<Duration> recordFailure() async {
    final prefs = await SharedPreferences.getInstance();
    final failures = (prefs.getInt(_prefFailures) ?? 0) + 1;
    await prefs.setInt(_prefFailures, failures);

    final delay = delayForFailures(failures);
    if (delay > Duration.zero) {
      await prefs.setInt(
        _prefLockedUntil,
        DateTime.now().add(delay).millisecondsSinceEpoch,
      );
    }
    return delay;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefFailures);
    await prefs.remove(_prefLockedUntil);
  }
}
