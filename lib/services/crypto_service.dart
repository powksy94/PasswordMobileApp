// lib/services/crypto_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' as pc;

/// Fournit : deriveKey(password, saltBase64), encryptText(plain, key), decryptText(json, key)
class CryptoService {
  /// Dérive une clé 32 bytes (AES-256) depuis un mot de passe et un salt (base64)
  static Uint8List deriveKey(String password, String saltBase64, {int iterations = 100000}) {
    final salt = base64Decode(saltBase64);
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    derivator.init(pc.Pbkdf2Parameters(salt, iterations, 32));
    final key = derivator.process(Uint8List.fromList(password.codeUnits));
    return key;
  }

  /// Chiffre avec AES-256-GCM (IV 12 bytes). Retourne JSON string contenant data + iv, base64.
  static String encryptText(String plain, Uint8List keyBytes) {
    final key = Key(keyBytes);
    final ivBytes = pc.SecureRandom().nextBytes(12);
    final iv = IV(ivBytes);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plain, iv: iv);
    final container = jsonEncode({
      'data': encrypted.base64,
      'iv': iv.base64,
    });
    return container;
  }

  /// Déchiffre le JSON renvoyé par encryptText
  static String decryptText(String cipherJson, Uint8List keyBytes) {
    final Map<String, dynamic> parsed = jsonDecode(cipherJson);
    final key = Key(keyBytes);
    final iv = IV.fromBase64(parsed['iv'] as String);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    return encrypter.decrypt64(parsed['data'] as String, iv: iv);
  }
}
