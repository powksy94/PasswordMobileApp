import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/services/crypto_service.dart';

Uint8List _key(int seed) =>
    Uint8List.fromList(List.generate(32, (i) => (i + seed) % 256));

void main() {
  group('CryptoService.encryptText / decryptText', () {
    test('roundtrip : encrypt → decrypt restitue le texte original', () {
      final key  = _key(0);
      const text = 'Hello, coffre-fort !';
      final cipher    = CryptoService.encryptText(text, key);
      final decrypted = CryptoService.decryptText(cipher, key);
      expect(decrypted, equals(text));
    });

    test('deux chiffrements du même texte produisent des ciphertexts différents (IV aléatoire)', () {
      final key = _key(0);
      final c1  = CryptoService.encryptText('same', key);
      final c2  = CryptoService.encryptText('same', key);
      expect(c1, isNot(equals(c2)));
    });

    test('déchiffrer avec la mauvaise clé lève une exception', () {
      final key1 = _key(0);
      final key2 = _key(42);
      final cipher = CryptoService.encryptText('secret', key1);
      expect(() => CryptoService.decryptText(cipher, key2), throwsException);
    });

    test('fonctionne avec texte vide', () {
      final key       = _key(1);
      final cipher    = CryptoService.encryptText('', key);
      final decrypted = CryptoService.decryptText(cipher, key);
      expect(decrypted, equals(''));
    });

    test('fonctionne avec texte long (> 1 Ko)', () {
      final key       = _key(2);
      final long      = 'A' * 2000;
      final cipher    = CryptoService.encryptText(long, key);
      final decrypted = CryptoService.decryptText(cipher, key);
      expect(decrypted, equals(long));
    });
  });

  group('CryptoService.deriveKey', () {
    final salt = base64Encode(Uint8List.fromList(List.generate(16, (i) => i)));

    test('produit une clé de 32 octets', () {
      expect(CryptoService.deriveKey('password', salt).length, equals(32));
    });

    test('est déterministe : même entrées → même clé', () {
      final k1 = CryptoService.deriveKey('password', salt);
      final k2 = CryptoService.deriveKey('password', salt);
      expect(k1, equals(k2));
    });

    test('mots de passe différents → clés différentes', () {
      final k1 = CryptoService.deriveKey('password1', salt);
      final k2 = CryptoService.deriveKey('password2', salt);
      expect(k1, isNot(equals(k2)));
    });

    test('salts différents → clés différentes', () {
      final salt2 = base64Encode(Uint8List.fromList(List.generate(16, (i) => i + 1)));
      final k1    = CryptoService.deriveKey('password', salt);
      final k2    = CryptoService.deriveKey('password', salt2);
      expect(k1, isNot(equals(k2)));
    });
  });
}
