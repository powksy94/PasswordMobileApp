import 'dart:typed_data';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/crypto_service.dart';

enum MasterPasswordCheck {
  /// At least one vault item decrypts with the derived key.
  matches,

  /// The vault contains items but none decrypts: incorrect master
  /// password.
  mismatch,

  /// Cannot decide (empty vault, vault unreachable): the caller
  /// must not block the user.
  unverifiable,
}

/// Checks that a master password entered at login really matches
/// the one that encrypted the existing vault, before its derived key is
/// persisted (verification reference, secure storage, biometrics).
///
/// Since the encryption is authenticated (AES-GCM), a wrong key always
/// fails at decryption.
class MasterPasswordVerifier {
  static final _api = ApiService();

  static Future<MasterPasswordCheck> checkAgainstServerVault({
    required String token,
    required String salt,
    required String masterPassword,
  }) async {
    final List<dynamic> raw;
    try {
      raw = await _api.getVault(token);
    } catch (_) {
      return MasterPasswordCheck.unverifiable;
    }
    return probe(raw, CryptoService.deriveKey(masterPassword, salt));
  }

  static MasterPasswordCheck probe(List<dynamic> raw, Uint8List key) {
    if (raw.isEmpty) return MasterPasswordCheck.unverifiable;
    for (final item in raw) {
      try {
        CryptoService.decryptText(item['title'] as String, key);
        return MasterPasswordCheck.matches;
      } catch (_) {
        continue;
      }
    }
    return MasterPasswordCheck.mismatch;
  }
}
