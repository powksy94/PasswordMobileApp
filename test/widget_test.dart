import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/generator/services/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('génère un mot de passe de la longueur demandée', () {
      final pwd = PasswordGenerator.generate(length: 20);
      expect(pwd.length, equals(20));
    });

    test('respecte les types de caractères activés', () {
      final pwd = PasswordGenerator.generate(
        length: 32,
        useLower: true,
        useUpper: false,
        useDigits: false,
        useSpecials: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[A-Z]').hasMatch(pwd), isFalse);
      expect(RegExp(r'[0-9]').hasMatch(pwd), isFalse);
    });

    test('exclut les caractères spécifiés', () {
      final pwd = PasswordGenerator.generate(length: 64, exclude: 'aeiou');
      expect(RegExp(r'[aeiou]').hasMatch(pwd), isFalse);
    });

    test('lève une exception si tous les caractères sont exclus', () {
      const alphabet = 'abcdefghijklmnopqrstuvwxyz'
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          '0123456789'
          r'!@#$%^&*()-_=+[]{};:,.?/<>|';
      expect(
        () => PasswordGenerator.generate(length: 8, exclude: alphabet),
        throwsException,
      );
    });
  });
}
