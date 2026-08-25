import '../../auth/services/auth_service.dart';
import '../../auth/services/master_key_service.dart';
import '../../../shared/services/api_service.dart';
import './vault_codec.dart';
import './vault_service.dart';

export 'vault_exceptions.dart';

/// Ré-chiffrement en masse du coffre (changement de mot de passe maître) —
/// isolé de [VaultService] : c'est une opération transactionnelle distincte
/// du CRUD simple, avec ses propres règles d'échec (voir doc de la méthode).
class VaultReencryptService {
  static final _api = ApiService();

  /// Déchiffre tout le coffre avec l'ancienne clé, le re-chiffre avec la
  /// nouvelle, puis envoie le tout en une seule transaction atomique côté
  /// serveur (`PUT /vault/reencrypt-all`). Si l'ancien mot de passe est
  /// incorrect → [WrongMasterPasswordException]. Si l'envoi échoue → le serveur
  /// annule toute la transaction (coffre intact) et [MasterPasswordChangeException]
  /// est levée ; la nouvelle clé n'est jamais persistée dans ce cas.
  static Future<void> changeMasterPassword({
    required String oldMasterPassword,
    required String newMasterPassword,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final validOld = await MasterKeyService.unlockWithMasterPassword(oldMasterPassword);
    if (!validOld) throw WrongMasterPasswordException();

    final newKey = await MasterKeyService.deriveKeyFromMasterPassword(newMasterPassword);
    if (newKey == null) throw Exception('Sel introuvable — compte invalide');

    final result = await VaultService.loadFromServer();
    final items  = result.items;

    // An item that fails to decrypt under the old key would simply be
    // missing from the re-encrypted batch sent to the server and lost for
    // good once the new key is committed — refuse instead of silently
    // re-encrypting an incomplete vault.
    if (result.skippedCount > 0) {
      throw MasterPasswordChangeException(
        'skipped items during re-encrypt: ${result.skippedCount}',
      );
    }

    if (items.isNotEmpty) {
      final reencrypted = items.map((item) => VaultCodec.encryptFields(
        id:       item.id,
        type:     item.type,
        label:    item.label,
        login:    item.login,
        password: item.password,
        notes:    item.notes,
        icon:     item.icon,
        url:      item.url,
        pin:      item.pin,
        key:      newKey,
      )).toList();

      try {
        await _api.reencryptVault(token, reencrypted);
      } catch (e) {
        throw MasterPasswordChangeException(e);
      }
    }

    await MasterKeyService.commitNewMasterKey(newKey);
    VaultService.vaultVersion.value++;
  }
}
