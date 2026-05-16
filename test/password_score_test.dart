import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/utils/password_score.dart';

void main() {
  group('PasswordScore.compute', () {
    test('mot de passe vide → 0', () {
      expect(PasswordScore.compute(''), equals(0));
    });

    test('score entre 0 et 100 pour tout mot de passe', () {
      for (final pw in ['a', 'abc123', 'A1!aaaaaaaaaaaaaaa', 'x' * 100]) {
        final s = PasswordScore.compute(pw);
        expect(s, inInclusiveRange(0, 100));
      }
    });

    test('mot de passe court simple → Faible (< 30)', () {
      expect(PasswordScore.compute('abc'), lessThan(30));
    });

    test('mot de passe long et complexe → Très fort (≥ 80)', () {
      expect(PasswordScore.compute('Aa1!Aa1!Aa1!Aa1!'), greaterThanOrEqualTo(80));
    });

    test('16 caractères sans complexité → score partiel', () {
      final s = PasswordScore.compute('aaaaaaaaaaaaaaaa'); // 16 lowercase
      // Longueur = 50, complexité mixte = 0 → 50 total
      expect(s, equals(50));
    });
  });

  group('PasswordScore.color', () {
    test('score faible → rouge', () {
      expect(PasswordScore.color(20), equals(Colors.redAccent));
    });

    test('score moyen → orange', () {
      expect(PasswordScore.color(45), equals(Colors.orangeAccent));
    });

    test('score fort → vert clair', () {
      expect(PasswordScore.color(70), equals(Colors.lightGreenAccent));
    });

    test('score très fort → cyan', () {
      expect(PasswordScore.color(90), equals(Colors.cyanAccent));
    });
  });

  group('PasswordScore.label', () {
    test('retourne Faible pour score < 30', () {
      expect(PasswordScore.label(0), equals('Faible'));
      expect(PasswordScore.label(29), equals('Faible'));
    });

    test('retourne Moyen pour score 30–59', () {
      expect(PasswordScore.label(30), equals('Moyen'));
      expect(PasswordScore.label(59), equals('Moyen'));
    });

    test('retourne Fort pour score 60–79', () {
      expect(PasswordScore.label(60), equals('Fort'));
      expect(PasswordScore.label(79), equals('Fort'));
    });

    test('retourne Très fort pour score ≥ 80', () {
      expect(PasswordScore.label(80), equals('Très fort'));
      expect(PasswordScore.label(100), equals('Très fort'));
    });
  });
}
