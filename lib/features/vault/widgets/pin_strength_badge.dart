import 'package:flutter/material.dart';
import '../../../shared/utils/pin_score.dart';

/// Petit badge coloré affichant la robustesse d'un PIN (calculée localement
/// depuis la valeur en clair, disponible côté client après déchiffrement —
/// pas besoin de dépendre de `pin_strength` renvoyé par le serveur pour
/// l'affichage).
class PinStrengthBadge extends StatelessWidget {
  final String pin;

  const PinStrengthBadge({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    final score = PinScore.compute(pin);
    final color = PinScore.color(score);
    final label = PinScore.label(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
