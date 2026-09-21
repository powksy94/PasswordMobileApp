// lib/services/vault_service.dart
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/vault_item.dart';
import '../../auth/services/auth_exceptions.dart';
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

  /// Incremented on every write to the vault (add, edit,
  /// delete, purge, re-encryption): global signal so that any page
  /// displaying vault items (VaultPage, PasswordHealthPage...)
  /// resynchronizes, whichever page triggered the change.
  static final ValueNotifier<int> vaultVersion = ValueNotifier(0);

  // ── Loading (network -> cache on failure) ────────────────────────────

  /// Returns the items, a [fromCache] flag telling whether the data comes
  /// from the cache, and [skippedCount]: the number of items present on the server/cache
  /// but that could not be decrypted (to report to the user rather
  /// than silently making them disappear from the vault).
  static Future<({List<VaultItem> items, bool fromCache, int skippedCount})> loadFromServer() async {
    final token = await AuthService.getToken();
    if (token == null) throw NotAuthenticatedException();
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw MasterKeyMissingException();

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

  // ── Write ──────────────────────────────────────────────────────────────

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
    if (token == null) throw NotAuthenticatedException();
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw MasterKeyMissingException();

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
    if (token == null) throw NotAuthenticatedException();
    final key = MasterKeyService.getMasterKey();
    if (key == null) throw MasterKeyMissingException();

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
    if (token == null) throw NotAuthenticatedException();
    await _api.deleteItem(token, id);
    vaultVersion.value++;
  }

  static Future<void> purgeAll() async {
    final token = await AuthService.getToken();
    if (token == null) throw NotAuthenticatedException();
    await _api.purgeVault(token);
    await VaultCache.save([]);
    vaultVersion.value++;
  }
}
