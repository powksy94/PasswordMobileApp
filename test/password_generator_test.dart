import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/generator/services/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('génère la longueur exacte demandée', () {
      for (final len in [4, 8, 16, 32, 64]) {
        expect(PasswordGenerator.generate(length: len).length, equals(len));
      }
    });

    test('respecte useLower = false', () {
      final pwd = PasswordGenerator.generate(
        length: 40,
        useLower: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[a-z]').hasMatch(pwd), isFalse);
    });

    test('respecte useUpper = false', () {
      final pwd = PasswordGenerator.generate(
        length: 40,
        useUpper: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[A-Z]').hasMatch(pwd), isFalse);
    });

    test('respecte useDigits = false', () {
      final pwd = PasswordGenerator.generate(
        length: 40,
        useDigits: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[0-9]').hasMatch(pwd), isFalse);
    });

    test('exclut les caractères spécifiés', () {
      final pwd = PasswordGenerator.generate(length: 64, exclude: 'aeiou0');
      expect(RegExp(r'[aeiou0]').hasMatch(pwd), isFalse);
    });

    test('requireAllTypes garantit la présence de chaque type', () {
      final pwd = PasswordGenerator.generate(
        length: 16,
        requireAllTypes: true,
      );
      expect(RegExp(r'[a-z]').hasMatch(pwd), isTrue);
      expect(RegExp(r'[A-Z]').hasMatch(pwd), isTrue);
      expect(RegExp(r'[0-9]').hasMatch(pwd), isTrue);
    });

    test('lève une exception si tous les caractères sont exclus', () {
      const all = 'abcdefghijklmnopqrstuvwxyz'
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          '0123456789'
          r'!@#$%^&*()-_=+[]{};:,.?/<>|';
      expect(
        () => PasswordGenerator.generate(length: 8, exclude: all),
        throwsException,
      );
    });

    test('deux appels successifs produisent des résultats différents', () {
      final a = PasswordGenerator.generate(length: 24);
      final b = PasswordGenerator.generate(length: 24);
      // Probabilité de collision négligeable sur 24 caractères
      expect(a, isNot(equals(b)));
    });
  });
}
