import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/utils/pin_score.dart';

void main() {
  group('PinScore.compute', () {
    test('pin vide → 0', () {
      expect(PinScore.compute(''), equals(0));
    });

    test('score entre 0 et 100 pour tout pin', () {
      for (final pin in ['0000', '482916', '12345678', '7512']) {
        expect(PinScore.compute(pin), inInclusiveRange(0, 100));
      }
    });

    test('1234 → weak (pin commun)', () {
      expect(PinScore.category(PinScore.compute('1234')), equals('weak'));
    });

    test('7512 → strong (un seul pattern : département 75)', () {
      expect(PinScore.compute('7512'), equals(80));
      expect(PinScore.category(PinScore.compute('7512')), equals('strong'));
    });

    test('0614 → medium (ressemble à une date MMYY + département 06)', () {
      expect(PinScore.compute('0614'), equals(40));
      expect(PinScore.category(PinScore.compute('0614')), equals('medium'));
    });

    test('8374 → strong (département 83)', () {
      expect(PinScore.compute('8374'), equals(80));
      expect(PinScore.category(PinScore.compute('8374')), equals('strong'));
    });

    test('291047 → medium (ressemble à une date 29/10/47 + département 29)', () {
      expect(PinScore.compute('291047'), equals(40));
      expect(PinScore.category(PinScore.compute('291047')), equals('medium'));
    });

    test('482916 → strong (département 48)', () {
      expect(PinScore.compute('482916'), equals(80));
      expect(PinScore.category(PinScore.compute('482916')), equals('strong'));
    });

    test('0000 → weak (répétition pure, pin commun)', () {
      expect(PinScore.category(PinScore.compute('0000')), equals('weak'));
    });

    test('9876 → medium (séquence stricte décroissante, seule, -60 sur 100)', () {
      expect(PinScore.compute('9876'), equals(40));
      expect(PinScore.category(PinScore.compute('9876')), equals('medium'));
    });

    test('2345 → weak (séquence + département 23 cumulés : -60-20)', () {
      expect(PinScore.compute('2345'), equals(20));
      expect(PinScore.category(PinScore.compute('2345')), equals('weak'));
    });

    test('2580 → medium (motif numpad + département 25 cumulés, -50-20=30 pile au seuil medium)', () {
      expect(PinScore.compute('2580'), equals(30));
      expect(PinScore.category(PinScore.compute('2580')), equals('medium'));
    });
  });

  group('PinScore.category', () {
    test('seuils weak/medium/strong', () {
      expect(PinScore.category(29), equals('weak'));
      expect(PinScore.category(30), equals('medium'));
      expect(PinScore.category(64), equals('medium'));
      expect(PinScore.category(65), equals('strong'));
    });
  });
}
