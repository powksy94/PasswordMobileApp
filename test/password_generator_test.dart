import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/generator/services/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('generates the exact requested length', () {
      for (final len in [4, 8, 16, 32, 64]) {
        expect(PasswordGenerator.generate(length: len).length, equals(len));
      }
    });

    test('respects useLower = false', () {
      final pwd = PasswordGenerator.generate(
        length: 40,
        useLower: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[a-z]').hasMatch(pwd), isFalse);
    });

    test('respects useUpper = false', () {
      final pwd = PasswordGenerator.generate(
        length: 40,
        useUpper: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[A-Z]').hasMatch(pwd), isFalse);
    });

    test('respects useDigits = false', () {
      final pwd = PasswordGenerator.generate(
        length: 40,
        useDigits: false,
        requireAllTypes: false,
      );
      expect(RegExp(r'[0-9]').hasMatch(pwd), isFalse);
    });

    test('excludes the specified characters', () {
      final pwd = PasswordGenerator.generate(length: 64, exclude: 'aeiou0');
      expect(RegExp(r'[aeiou0]').hasMatch(pwd), isFalse);
    });

    test('requireAllTypes guarantees the presence of each type', () {
      final pwd = PasswordGenerator.generate(
        length: 16,
        requireAllTypes: true,
      );
      expect(RegExp(r'[a-z]').hasMatch(pwd), isTrue);
      expect(RegExp(r'[A-Z]').hasMatch(pwd), isTrue);
      expect(RegExp(r'[0-9]').hasMatch(pwd), isTrue);
    });

    test('throws an exception if all characters are excluded', () {
      const all = 'abcdefghijklmnopqrstuvwxyz'
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          '0123456789'
          r'!@#$%^&*()-_=+[]{};:,.?/<>|';
      expect(
        () => PasswordGenerator.generate(length: 8, exclude: all),
        throwsException,
      );
    });

    test('two successive calls produce different results', () {
      final a = PasswordGenerator.generate(length: 24);
      final b = PasswordGenerator.generate(length: 24);
      // Negligible collision probability over 24 characters
      expect(a, isNot(equals(b)));
    });
  });
}
