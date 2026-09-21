import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/auth/services/unlock_throttle.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UnlockThrottle.delayForFailures', () {
    test('aucun délai pour les premières erreurs', () {
      for (var i = 0; i < UnlockThrottle.freeAttempts; i++) {
        expect(UnlockThrottle.delayForFailures(i), Duration.zero);
      }
    });

    test('30 s à la 5e erreur puis doublement', () {
      expect(UnlockThrottle.delayForFailures(5), const Duration(seconds: 30));
      expect(UnlockThrottle.delayForFailures(6), const Duration(seconds: 60));
      expect(UnlockThrottle.delayForFailures(7), const Duration(seconds: 120));
    });

    test('plafonné à 15 minutes', () {
      expect(UnlockThrottle.delayForFailures(10), UnlockThrottle.maxDelay);
      expect(UnlockThrottle.delayForFailures(500), UnlockThrottle.maxDelay);
    });
  });

  group('UnlockThrottle persistance', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('libre tant que le seuil n\'est pas atteint', () async {
      for (var i = 0; i < UnlockThrottle.freeAttempts - 1; i++) {
        expect(await UnlockThrottle.recordFailure(), Duration.zero);
      }
      expect(await UnlockThrottle.remaining(), Duration.zero);
    });

    test('verrouille à la 5e erreur puis reset libère', () async {
      for (var i = 0; i < UnlockThrottle.freeAttempts - 1; i++) {
        await UnlockThrottle.recordFailure();
      }
      final delay = await UnlockThrottle.recordFailure();
      expect(delay, const Duration(seconds: 30));
      expect(await UnlockThrottle.remaining(), greaterThan(Duration.zero));

      await UnlockThrottle.reset();
      expect(await UnlockThrottle.remaining(), Duration.zero);
    });
  });
}
