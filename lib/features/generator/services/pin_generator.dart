import 'dart:math';
import '../../../shared/utils/pin_score.dart';

/// Génération de PIN, volontairement indépendante de [PasswordGenerator] —
/// voir PIN_VAULT_SPEC.md (alphabet, contraintes et critère de rejet n'ont
/// rien en commun avec la génération de mots de passe).
class PinGenerator {
  static const _maxAttempts = 200;

  /// Génère un PIN de [length] chiffres (4 ou 6), rejeté et régénéré tant
  /// qu'il score `weak` sur [PinScore] — garantit au moins `medium`.
  static String generate({int length = 4}) {
    final rand = Random.secure();
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final pin = List.generate(length, (_) => rand.nextInt(10)).join();
      if (PinScore.category(PinScore.compute(pin)) != 'weak') return pin;
    }
    // Filet de sécurité si _maxAttempts est atteint (statistiquement
    // quasi-impossible) : renvoie le dernier candidat plutôt que boucler
    // indéfiniment ou planter.
    return List.generate(length, (_) => rand.nextInt(10)).join();
  }
}
