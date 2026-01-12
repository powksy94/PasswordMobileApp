import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  /// Calcul de la force du mot de passe (0 à 100) de façon progressive
  int get strength {
    if (password.isEmpty) return 0;

    double score = 0;

    // 1️⃣ Longueur : jusqu'à 50 points
    int length = password.length;
    if (length >= 16) {
      score += 50;
    } else {
      score += (length / 16) * 50; // proportionnel jusqu'à 16 caractères
    }

    // 2️⃣ Complexité : majuscules/minuscules, chiffres, spéciaux (chaque critère 16, total 50)
    int complexityPoints = 0;

    if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) {
      complexityPoints += 16;
    }

    if (RegExp(r'\d').hasMatch(password)) complexityPoints += 17;

    if (RegExp(r'[!@#\$&*~%^&()_\-+=]').hasMatch(password)) complexityPoints += 17;

    score += complexityPoints;

    return score.clamp(0, 100).toInt();
  }

  Color get color {
    if (strength < 30) return Colors.redAccent;
    if (strength < 60) return Colors.orangeAccent;
    if (strength < 80) return Colors.lightGreenAccent;
    return Colors.cyanAccent;
  }

  String get label {
    if (strength < 30) return "Faible";
    if (strength < 60) return "Moyen";
    if (strength < 80) return "Fort";
    return "Très fort";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
