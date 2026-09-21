import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/generator/services/pin_generator.dart';
import 'package:password_mobile_app/shared/utils/pin_score.dart';

void main() {
  group('PinGenerator', () {
    test('generates the exact requested length (4 and 6)', () {
      for (final len in [4, 6]) {
        expect(PinGenerator.generate(length: len).length, equals(len));
      }
    });

    test('only generates digits', () {
      final pin = PinGenerator.generate(length: 6);
      expect(RegExp(r'^[0-9]+$').hasMatch(pin), isTrue);
    });

    test('never returns a PIN scored weak', () {
      for (var i = 0; i < 50; i++) {
        final pin = PinGenerator.generate(length: 4);
        expect(PinScore.category(PinScore.compute(pin)), isNot(equals('weak')));
      }
    });

    test('two successive calls generally produce different results', () {
      final a = PinGenerator.generate(length: 6);
      final b = PinGenerator.generate(length: 6);
      expect(a, isNot(equals(b)));
    });
  });
}
