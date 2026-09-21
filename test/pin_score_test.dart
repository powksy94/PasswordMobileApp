import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/utils/pin_score.dart';
import 'package:password_mobile_app/shared/utils/strength_level.dart';

void main() {
  group('PinScore.level', () {
    test('weak for score < 30', () {
      expect(PinScore.level(0), StrengthLevel.weak);
      expect(PinScore.level(29), StrengthLevel.weak);
    });

    test('medium for score 30-64', () {
      expect(PinScore.level(30), StrengthLevel.medium);
      expect(PinScore.level(64), StrengthLevel.medium);
    });

    test('strong for score >= 65, never veryStrong', () {
      expect(PinScore.level(65), StrengthLevel.strong);
      expect(PinScore.level(100), StrengthLevel.strong);
    });
  });

  group('PinScore.compute', () {
    test('empty pin -> 0', () {
      expect(PinScore.compute(''), equals(0));
    });

    test('score between 0 and 100 for any pin', () {
      for (final pin in ['0000', '482916', '12345678', '7512']) {
        expect(PinScore.compute(pin), inInclusiveRange(0, 100));
      }
    });

    test('1234 -> weak (common pin)', () {
      expect(PinScore.category(PinScore.compute('1234')), equals('weak'));
    });

    test('7512 -> strong (a single pattern: department 75)', () {
      expect(PinScore.compute('7512'), equals(80));
      expect(PinScore.category(PinScore.compute('7512')), equals('strong'));
    });

    test('0614 -> medium (looks like a MMYY date + department 06)', () {
      expect(PinScore.compute('0614'), equals(40));
      expect(PinScore.category(PinScore.compute('0614')), equals('medium'));
    });

    test('8374 -> strong (department 83)', () {
      expect(PinScore.compute('8374'), equals(80));
      expect(PinScore.category(PinScore.compute('8374')), equals('strong'));
    });

    test('291047 -> medium (looks like a date 29/10/47 + department 29)', () {
      expect(PinScore.compute('291047'), equals(40));
      expect(PinScore.category(PinScore.compute('291047')), equals('medium'));
    });

    test('482916 -> strong (department 48)', () {
      expect(PinScore.compute('482916'), equals(80));
      expect(PinScore.category(PinScore.compute('482916')), equals('strong'));
    });

    test('0000 -> weak (pure repetition, common pin)', () {
      expect(PinScore.category(PinScore.compute('0000')), equals('weak'));
    });

    test('9876 -> medium (strict decreasing sequence, alone, -60 out of 100)', () {
      expect(PinScore.compute('9876'), equals(40));
      expect(PinScore.category(PinScore.compute('9876')), equals('medium'));
    });

    test('2345 -> weak (sequence + department 23 combined: -60-20)', () {
      expect(PinScore.compute('2345'), equals(20));
      expect(PinScore.category(PinScore.compute('2345')), equals('weak'));
    });

    test('2580 -> medium (numpad pattern + department 25 combined, -50-20=30 exactly at the medium threshold)', () {
      expect(PinScore.compute('2580'), equals(30));
      expect(PinScore.category(PinScore.compute('2580')), equals('medium'));
    });
  });

  group('PinScore.category', () {
    test('weak/medium/strong thresholds', () {
      expect(PinScore.category(29), equals('weak'));
      expect(PinScore.category(30), equals('medium'));
      expect(PinScore.category(64), equals('medium'));
      expect(PinScore.category(65), equals('strong'));
    });
  });
}
