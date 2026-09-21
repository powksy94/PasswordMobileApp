import 'package:flutter/material.dart';
import './strength_level.dart';

/// Calcul de la force d'un mot de passe — logique partagée entre
/// [PasswordStrengthBar], [PasswordHealthPage] et tout widget qui en a besoin.
class PasswordScore {
  const PasswordScore._();

  /// Score de 0 à 100.
  static int compute(String password) {
    if (password.isEmpty) return 0;
    double s = 0;
    final len = password.length;
    s += len >= 16 ? 50 : (len / 16) * 50;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) { s += 16; }
    if (RegExp(r'\d').hasMatch(password)) s += 17;
    if (RegExp(r'[!@#\$&*~%^&()_\-+=]').hasMatch(password)) s += 17;
    return s.clamp(0, 100).toInt();
  }

  static Color color(int score) {
    if (score < 30) return Colors.redAccent;
    if (score < 60) return Colors.orangeAccent;
    if (score < 80) return Colors.lightGreenAccent;
    return Colors.cyanAccent;
  }

  static StrengthLevel level(int score) {
    if (score < 30) return StrengthLevel.weak;
    if (score < 60) return StrengthLevel.medium;
    if (score < 80) return StrengthLevel.strong;
    return StrengthLevel.veryStrong;
  }

  /// Catégorie technique à 3 niveaux ('weak' | 'medium' | 'strong'), seule
  /// information envoyée au serveur pour les statistiques admin — distincte de
  /// [level], qui reste un niveau d'affichage à 4 paliers pour l'utilisateur.
  static String category(int score) {
    if (score < 30) return 'weak';
    if (score < 60) return 'medium';
    return 'strong';
  }
}
