import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/utils/password_score.dart';
import 'package:password_mobile_app/shared/utils/strength_level.dart';

void main() {
  group('PasswordScore.compute', () {
    test('empty password -> 0', () {
      expect(PasswordScore.compute(''), equals(0));
    });

    test('score between 0 and 100 for any password', () {
      for (final pw in ['a', 'abc123', 'A1!aaaaaaaaaaaaaaa', 'x' * 100]) {
        final s = PasswordScore.compute(pw);
        expect(s, inInclusiveRange(0, 100));
      }
    });

    test('short simple password -> weak (< 30)', () {
      expect(PasswordScore.compute('abc'), lessThan(30));
    });

    test('long complex password -> very strong (>= 80)', () {
      expect(PasswordScore.compute('Aa1!Aa1!Aa1!Aa1!'), greaterThanOrEqualTo(80));
    });

    test('16 characters without complexity -> partial score', () {
      final s = PasswordScore.compute('aaaaaaaaaaaaaaaa'); // 16 lowercase
      // Length = 50, mixed complexity = 0 -> 50 total
      expect(s, equals(50));
    });
  });

  group('PasswordScore.color', () {
    test('weak score -> red', () {
      expect(PasswordScore.color(20), equals(Colors.redAccent));
    });

    test('medium score -> orange', () {
      expect(PasswordScore.color(45), equals(Colors.orangeAccent));
    });

    test('strong score -> light green', () {
      expect(PasswordScore.color(70), equals(Colors.lightGreenAccent));
    });

    test('very strong score -> cyan', () {
      expect(PasswordScore.color(90), equals(Colors.cyanAccent));
    });
  });

  group('PasswordScore.level', () {
    test('weak for score < 30', () {
      expect(PasswordScore.level(0), equals(StrengthLevel.weak));
      expect(PasswordScore.level(29), equals(StrengthLevel.weak));
    });

    test('medium for score 30-59', () {
      expect(PasswordScore.level(30), equals(StrengthLevel.medium));
      expect(PasswordScore.level(59), equals(StrengthLevel.medium));
    });

    test('strong for score 60-79', () {
      expect(PasswordScore.level(60), equals(StrengthLevel.strong));
      expect(PasswordScore.level(79), equals(StrengthLevel.strong));
    });

    test('veryStrong for score >= 80', () {
      expect(PasswordScore.level(80), equals(StrengthLevel.veryStrong));
      expect(PasswordScore.level(100), equals(StrengthLevel.veryStrong));
    });
  });
}
