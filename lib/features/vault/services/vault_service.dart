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

  /// Incrémenté à chaque écriture sur le coffre (ajout, modification,
  /// suppression, purge, ré-encryption) — signal global pour que toute page
  /// affichant des items du coffre (VaultPage, PasswordHealthPage…) se
  /// resynchronise, quelle que soit la page qui a déclenché le changement.
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
    String type  = 'password',
    String login = '',
    String notes = '',
    String icon  = 'lock',
    String url   = '',
    String pin   = '',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw Exception('Master key absente');

    await _api.addItem(token, VaultCodec.encryptFields(
      id:       _uuid.v4(),
      type:     type,
      label:    label,
      login:    login,
      password: password,
      notes:    notes,
      icon:     icon,
      url:      url,
      pin:      pin,
      key:      key,
    ));
    vaultVersion.value++;
  }

  static Future<void> updateOnServer({
    required String id,
    required String label,
    required String password,
    String type  = 'password',
    String login = '',
    String notes = '',
    String icon  = 'lock',
    String url   = '',
    String pin   = '',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw Exception('Master key absente');

    await _api.updateItem(token, id, VaultCodec.encryptFields(
      type:     type,
      label:    label,
      login:    login,
      password: password,
      notes:    notes,
      icon:     icon,
      url:      url,
      pin:      pin,
      key:      key,
    ));
    vaultVersion.value++;
  }

  static Future<void> deleteFromServer(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    await _api.deleteItem(token, id);
    vaultVersion.value++;
  }

  static Future<void> purgeAll() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    await _api.purgeVault(token);
    await VaultCache.save([]);
    vaultVersion.value++;
  }
}
