import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/generator/services/pin_generator.dart';
import 'package:password_mobile_app/shared/utils/pin_score.dart';

void main() {
  group('PinGenerator', () {
    test('génère la longueur exacte demandée (4 et 6)', () {
      for (final len in [4, 6]) {
        expect(PinGenerator.generate(length: len).length, equals(len));
      }
    });

    test('ne génère que des chiffres', () {
      final pin = PinGenerator.generate(length: 6);
      expect(RegExp(r'^[0-9]+$').hasMatch(pin), isTrue);
    });

    test('ne renvoie jamais un PIN scoré weak', () {
      for (var i = 0; i < 50; i++) {
        final pin = PinGenerator.generate(length: 4);
        expect(PinScore.category(PinScore.compute(pin)), isNot(equals('weak')));
      }
    });

    test('deux appels successifs produisent généralement des résultats différents', () {
      final a = PinGenerator.generate(length: 6);
      final b = PinGenerator.generate(length: 6);
      expect(a, isNot(equals(b)));
    });
  });
}
