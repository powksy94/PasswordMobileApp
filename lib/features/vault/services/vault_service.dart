// lib/services/vault_service.dart
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/vault_item.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/master_key_service.dart';
import '../../../shared/services/autofill_cache_service.dart';
import './vault_cache.dart';
import './vault_codec.dart';
import './vault_exceptions.dart';
import 'package:uuid/uuid.dart';

export 'vault_exceptions.dart';

class VaultService {
  static final _api  = ApiService();
  static final _uuid = Uuid();

  /// Incrémenté quand le coffre change depuis l'extérieur de [VaultPage]
  /// (ex: import depuis les Paramètres) pour signaler un rechargement.
  static final ValueNotifier<int> vaultVersion = ValueNotifier(0);

  // ── Chargement (réseau → cache en cas d'échec) ────────────────────────────

  /// Retourne les items, un flag [fromCache] indiquant si les données viennent
  /// du cache, et [skippedCount] : le nombre d'items présents côté serveur/cache
  /// mais qui n'ont pas pu être déchiffrés (à signaler à l'utilisateur plutôt
  /// que de les faire disparaître silencieusement du coffre).
  static Future<({List<VaultItem> items, bool fromCache, int skippedCount})> loadFromServer() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw Exception('Master key absente — déverrouillez le vault');

    try {
      final raw    = await _api.getVault(token);
      await VaultCache.save(raw);
      final result = VaultCodec.decryptRaw(raw, key);
      if (raw.isNotEmpty && result.items.isEmpty) {
        throw const VaultDecryptionException();
      }
      AutofillCacheService.update(result.items).ignore();
      return (items: result.items, fromCache: false, skippedCount: result.skipped);
    } on VaultDecryptionException {
      rethrow;
    } catch (_) {
      final cached = await VaultCache.load();
      if (cached == null) rethrow;
      final result = VaultCodec.decryptRaw(cached, key);
      if (cached.isNotEmpty && result.items.isEmpty) throw const VaultDecryptionException();
      return (items: result.items, fromCache: true, skippedCount: result.skipped);
    }
  }

  // ── Écriture ──────────────────────────────────────────────────────────────

  static Future<void> addToServer({
    required String label,
    required String password,
    String login = '',
    String notes = '',
    String icon  = 'lock',
    String url   = '',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw Exception('Master key absente');

    await _api.addItem(token, VaultCodec.encryptFields(
      id:       _uuid.v4(),
      label:    label,
      login:    login,
      password: password,
      notes:    notes,
      icon:     icon,
      url:      url,
      key:      key,
    ));
  }

  static Future<void> updateOnServer({
    required String id,
    required String label,
    required String password,
    String login = '',
    String notes = '',
    String icon  = 'lock',
    String url   = '',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw Exception('Master key absente');

    await _api.updateItem(token, id, VaultCodec.encryptFields(
      label:    label,
      login:    login,
      password: password,
      notes:    notes,
      icon:     icon,
      url:      url,
      key:      key,
    ));
  }

  // ── Changement du mot de passe maître ─────────────────────────────────────

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

    final result = await loadFromServer();
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
        label:    item.label,
        login:    item.login,
        password: item.password,
        notes:    item.notes,
        icon:     item.icon,
        url:      item.url,
        key:      newKey,
      )).toList();

      try {
        await _api.reencryptVault(token, reencrypted);
      } catch (e) {
        throw MasterPasswordChangeException(e);
      }
    }

    await MasterKeyService.commitNewMasterKey(newKey);
    vaultVersion.value++;
  }

  static Future<void> deleteFromServer(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    await _api.deleteItem(token, id);
  }

  static Future<void> purgeAll() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    await _api.purgeVault(token);
    await VaultCache.save([]);
    vaultVersion.value++;
  }
}
