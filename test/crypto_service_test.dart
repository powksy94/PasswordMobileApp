import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/services/crypto_service.dart';

Uint8List _key(int seed) =>
    Uint8List.fromList(List.generate(32, (i) => (i + seed) % 256));

void main() {
  group('CryptoService.encryptText / decryptText', () {
    test('roundtrip: encrypt -> decrypt restores the original text', () {
      final key  = _key(0);
      const text = 'Hello, coffre-fort !';
      final cipher    = CryptoService.encryptText(text, key);
      final decrypted = CryptoService.decryptText(cipher, key);
      expect(decrypted, equals(text));
    });

    test('two encryptions of the same text produce different ciphertexts (random IV)', () {
      final key = _key(0);
      final c1  = CryptoService.encryptText('same', key);
      final c2  = CryptoService.encryptText('same', key);
      expect(c1, isNot(equals(c2)));
    });

    test('decrypting with the wrong key throws an exception', () {
      final key1 = _key(0);
      final key2 = _key(42);
      final cipher = CryptoService.encryptText('secret', key1);
      expect(() => CryptoService.decryptText(cipher, key2), throwsException);
    });

    test('works with empty text', () {
      final key       = _key(1);
      final cipher    = CryptoService.encryptText('', key);
      final decrypted = CryptoService.decryptText(cipher, key);
      expect(decrypted, equals(''));
    });

    test('works with long text (> 1 KB)', () {
      final key       = _key(2);
      final long      = 'A' * 2000;
      final cipher    = CryptoService.encryptText(long, key);
      final decrypted = CryptoService.decryptText(cipher, key);
      expect(decrypted, equals(long));
    });
  });

  group('CryptoService.deriveKey', () {
    final salt = base64Encode(Uint8List.fromList(List.generate(16, (i) => i)));

    test('produces a 32-byte key', () {
      expect(CryptoService.deriveKey('password', salt).length, equals(32));
    });

    test('is deterministic: same inputs -> same key', () {
      final k1 = CryptoService.deriveKey('password', salt);
      final k2 = CryptoService.deriveKey('password', salt);
      expect(k1, equals(k2));
    });

    test('different passwords -> different keys', () {
      final k1 = CryptoService.deriveKey('password1', salt);
      final k2 = CryptoService.deriveKey('password2', salt);
      expect(k1, isNot(equals(k2)));
    });

    test('different salts -> different keys', () {
      final salt2 = base64Encode(Uint8List.fromList(List.generate(16, (i) => i + 1)));
      final k1    = CryptoService.deriveKey('password', salt);
      final k2    = CryptoService.deriveKey('password', salt2);
      expect(k1, isNot(equals(k2)));
    });
  });
}
