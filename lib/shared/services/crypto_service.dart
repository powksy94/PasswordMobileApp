// lib/services/crypto_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' as pc;

/// Provides: deriveKey(password, saltBase64), encryptText(plain, key), decryptText(json, key)
class CryptoService {
  /// Derives a 32-byte key (AES-256) from a password and a salt (base64)
  static Uint8List deriveKey(String password, String saltBase64, {int iterations = 100000}) {
    final salt = base64Decode(saltBase64);
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    derivator.init(pc.Pbkdf2Parameters(salt, iterations, 32));
    final key = derivator.process(Uint8List.fromList(utf8.encode(password)));
    return key;
  }

  /// Encrypts with AES-256-GCM (12-byte IV). Returns a JSON string containing data + iv, base64.
  static String encryptText(String plain, Uint8List keyBytes) {
    final key = Key(keyBytes);
    final rng     = Random.secure();
    final ivBytes = Uint8List.fromList(List.generate(12, (_) => rng.nextInt(256)));
    final iv = IV(ivBytes);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plain, iv: iv);
    final container = jsonEncode({
      'data': encrypted.base64,
      'iv': iv.base64,
    });
    return container;
  }

  /// Decrypts the JSON returned by encryptText
  static String decryptText(String cipherJson, Uint8List keyBytes) {
    final Map<String, dynamic> parsed = jsonDecode(cipherJson);
    final key = Key(keyBytes);
    final iv = IV.fromBase64(parsed['iv'] as String);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    return encrypter.decrypt64(parsed['data'] as String, iv: iv);
  }
}
