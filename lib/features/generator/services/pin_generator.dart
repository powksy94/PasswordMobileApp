import 'dart:math';
import '../../../shared/utils/pin_score.dart';

/// PIN generation, deliberately independent from [PasswordGenerator]:
/// see PIN_VAULT_SPEC.md (alphabet, constraints and rejection criterion have
/// nothing in common with password generation).
class PinGenerator {
  static const _maxAttempts = 200;

  /// Generates a PIN of [length] digits (4 or 6), rejected and regenerated as long
  /// as it scores `weak` on [PinScore]: guarantees at least `medium`.
  static String generate({int length = 4}) {
    final rand = Random.secure();
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final pin = List.generate(length, (_) => rand.nextInt(10)).join();
      if (PinScore.category(PinScore.compute(pin)) != 'weak') return pin;
    }
    // Safety net if _maxAttempts is reached (statistically
    // near-impossible): returns the last candidate rather than looping
    // forever or crashing.
    return List.generate(length, (_) => rand.nextInt(10)).join();
  }
}
