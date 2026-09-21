import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Slows down repeated master password attempts on the lock
/// screen: the first [freeAttempts] errors have no delay, then each
/// additional error doubles the wait ([baseDelay], capped at
/// [maxDelay]). The state is persisted so that a simple app restart
/// does not reset the counter to zero.
class UnlockThrottle {
  static const freeAttempts = 5;
  static const baseDelay    = Duration(seconds: 30);
  static const maxDelay     = Duration(minutes: 15);

  static const _prefFailures    = 'unlock_failed_attempts';
  static const _prefLockedUntil = 'unlock_locked_until_ms';

  /// Wait imposed after [failures] consecutive errors.
  static Duration delayForFailures(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final doublings = min(failures - freeAttempts, 5);
    final delay = baseDelay * pow(2, doublings).toInt();
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Time left before the next allowed attempt (zero = free).
  static Future<Duration> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_prefLockedUntil);
    if (until == null) return Duration.zero;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    return left > 0 ? Duration(milliseconds: left) : Duration.zero;
  }

  /// Records a failure and returns the resulting wait.
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
