import 'package:flutter/material.dart';

/// Calcul de robustesse d'un code PIN — voir PIN_VAULT_SPEC.md pour l'algorithme
/// et le détail des pénalités. Logique volontairement indépendante de
/// [PasswordScore] : alphabet, critères et seuils n'ont rien en commun.
///
/// Les pénalités s'additionnent (un PIN peut cumuler plusieurs signaux, ex.
/// "ressemble à une date" + "commence par un département") — seule la
/// détection d'un PIN de la liste des plus communs court-circuite le calcul
/// à 0, tout le reste est ignoré dans ce cas.
class PinScore {
  const PinScore._();

  static const _commonPins = <String>{
    '0000', '1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888', '9999',
    '1234', '4321', '1212', '1122', '1221', '1004', '2000', '2001', '6969', '1010',
    '1313', '1337',
    '000000', '111111', '123456', '654321', '123123', '696969', '123321', '112233',
  };

  static const _numpadPatterns = <String>{'2580', '1470', '1236', '7410', '1597'};

  static int compute(String pin) {
    if (pin.isEmpty) return 0;
    if (_commonPins.contains(pin)) return 0;

    var score = 100;
    if (_isStrictSequence(pin)) score -= 60;
    if (_isRepetitionOrAlternating(pin)) score -= 60;
    if (_numpadPatterns.contains(pin)) score -= 50;
    if (_looksLikeDate(pin)) score -= 40;
    if (_startsWithFrenchDepartment(pin)) score -= 20;

    return score.clamp(0, 100);
  }

  static String category(int score) {
    if (score < 30) return 'weak';
    if (score < 65) return 'medium';
    return 'strong';
  }

  static String label(int score) {
    if (score < 30) return 'Faible';
    if (score < 65) return 'Moyen';
    return 'Fort';
  }

  static Color color(int score) {
    if (score < 30) return Colors.redAccent;
    if (score < 65) return Colors.orangeAccent;
    return Colors.lightGreenAccent;
  }

  // ── Détections ────────────────────────────────────────────────────────────────

  static bool _isStrictSequence(String pin) {
    final digits = pin.split('').map(int.parse).toList();
    if (digits.length < 3) return false;
    final diffs = List.generate(digits.length - 1, (i) => digits[i + 1] - digits[i]);
    return diffs.every((d) => d == 1) || diffs.every((d) => d == -1);
  }

  static bool _isRepetitionOrAlternating(String pin) {
    if (pin.split('').every((c) => c == pin[0])) return true; // 0000, 111111…
    if (pin == pin.split('').reversed.join())     return true; // miroir : 1221, 123321…

    if (pin.length.isEven) {
      // Alternance période 2 : 1212, 121212…
      if (List.generate(pin.length, (i) => pin[i] == pin[i % 2]).every((v) => v)) {
        return true;
      }
      // Paires répétées : 1122, 112233…
      if (List.generate(pin.length ~/ 2, (i) => pin[2 * i] == pin[2 * i + 1]).every((v) => v)) {
        return true;
      }
    }
    return false;
  }

  static bool _looksLikeDate(String pin) {
    switch (pin.length) {
      case 4:
        final ddmm = _isValidDay(pin.substring(0, 2)) && _isValidMonth(pin.substring(2, 4));
        final mmyy = _isValidMonth(pin.substring(0, 2)); // yy = 2 derniers chiffres, toujours plausible
        final yyyy = _isPlausibleYear4(pin);
        return ddmm || mmyy || yyyy;
      case 6:
        final ddmmyy   = _isValidDay(pin.substring(0, 2)) && _isValidMonth(pin.substring(2, 4));
        final mmyyyy   = _isValidMonth(pin.substring(0, 2)) && _isPlausibleYear4(pin.substring(2, 6));
        return ddmmyy || mmyyyy;
      case 8:
        return _isValidDay(pin.substring(0, 2)) &&
            _isValidMonth(pin.substring(2, 4)) &&
            _isPlausibleYear4(pin.substring(4, 8));
      default:
        return false;
    }
  }

  static bool _isValidDay(String s)   { final d = int.parse(s); return d >= 1 && d <= 31; }
  static bool _isValidMonth(String s) { final m = int.parse(s); return m >= 1 && m <= 12; }
  static bool _isPlausibleYear4(String s) { final y = int.parse(s); return y >= 1900 && y <= 2099; }

  static bool _startsWithFrenchDepartment(String pin) {
    if (pin.length >= 3 && const {'971', '972', '973', '974', '975', '976'}.contains(pin.substring(0, 3))) {
      return true;
    }
    if (pin.length >= 2) {
      final two = int.parse(pin.substring(0, 2));
      return two >= 1 && two <= 95;
    }
    return false;
  }
}
