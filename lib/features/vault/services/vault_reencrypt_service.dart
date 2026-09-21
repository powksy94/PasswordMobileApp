import '../../auth/services/auth_exceptions.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/master_key_service.dart';
import '../../../shared/services/api_service.dart';
import './vault_codec.dart';
import './vault_service.dart';

export 'vault_exceptions.dart';

/// Bulk re-encryption of the vault (master password change),
/// isolated from [VaultService] because it is a transactional operation distinct
/// from simple CRUD, with its own failure rules (see the method doc).
class VaultReencryptService {
  static final _api = ApiService();

  /// Decrypts the whole vault with the old key, re-encrypts it with the
  /// new one, then sends everything in a single atomic transaction on the
  /// server (`PUT /vault/reencrypt-all`). If the old password is
  /// incorrect -> [WrongMasterPasswordException]. If sending fails -> the server
  /// cancels the whole transaction (vault intact) and [MasterPasswordChangeException]
  /// is thrown; the new key is never persisted in that case.
  static Future<void> changeMasterPassword({
    required String oldMasterPassword,
    required String newMasterPassword,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw NotAuthenticatedException();

    final validOld = await MasterKeyService.unlockWithMasterPassword(oldMasterPassword);
    if (!validOld) throw WrongMasterPasswordException();

    final newKey = await MasterKeyService.deriveKeyFromMasterPassword(newMasterPassword);
    if (newKey == null) throw AccountSaltMissingException();

    final result = await VaultService.loadFromServer();
    final items  = result.items;

    // An item that fails to decrypt under the old key would simply be
    // missing from the re-encrypted batch sent to the server and lost for
    // good once the new key is committed - refuse instead of silently
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
