// lib/services/vault_service.dart
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/vault_item.dart';
import '../../auth/services/auth_service.dart';
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

  /// Retourne les items et un flag [fromCache] indiquant si les données viennent du cache.
  static Future<({List<VaultItem> items, bool fromCache})> loadFromServer() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception('Master key absente — déverrouillez le vault');

    try {
      final raw   = await _api.getVault(token);
      await VaultCache.save(raw);
      final items = VaultCodec.decryptRaw(raw, key);
      AutofillCacheService.update(items).ignore();
      return (items: items, fromCache: false);
    } catch (_) {
      final cached = await VaultCache.load();
      if (cached == null) rethrow;
      return (items: VaultCodec.decryptRaw(cached, key), fromCache: true);
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
    final key = AuthService.getMasterKey();
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
    final key = AuthService.getMasterKey();
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

    final validOld = await AuthService.unlockWithMasterPassword(oldMasterPassword);
    if (!validOld) throw WrongMasterPasswordException();

    final newKey = await AuthService.deriveKeyFromMasterPassword(newMasterPassword);
    if (newKey == null) throw Exception('Sel introuvable — compte invalide');

    final result = await loadFromServer();
    final items  = result.items;

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

    await AuthService.commitNewMasterKey(newKey);
    vaultVersion.value++;
  }

  static Future<void> deleteFromServer(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    await _api.deleteItem(token, id);
  }
}
