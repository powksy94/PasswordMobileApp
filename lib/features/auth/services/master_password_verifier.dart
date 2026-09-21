import 'dart:typed_data';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/crypto_service.dart';

enum MasterPasswordCheck {
  /// Au moins un item du coffre se déchiffre avec la clé dérivée.
  matches,

  /// Le coffre contient des items mais aucun ne se déchiffre : mot de passe
  /// maître incorrect.
  mismatch,

  /// Impossible de trancher (coffre vide, coffre injoignable) : l'appelant
  /// ne doit pas bloquer l'utilisateur.
  unverifiable,
}

/// Vérifie qu'un mot de passe maître saisi à la connexion correspond bien à
/// celui qui a chiffré le coffre existant, avant que sa clé dérivée ne soit
/// persistée (référence de vérification, stockage sécurisé, biométrie).
///
/// Le chiffrement étant authentifié (AES-GCM), une mauvaise clé échoue
/// toujours au déchiffrement.
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
