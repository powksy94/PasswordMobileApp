import 'package:flutter/foundation.dart';
import '../../../shared/services/crypto_service.dart';
import '../../../shared/utils/password_score.dart';
import '../../../shared/utils/pin_score.dart';
import '../models/vault_item.dart';

/// Converts [VaultItem]s to/from their encrypted representation
/// exchanged with the server. Centralizes the field encryption/decryption
/// logic, shared by adding, editing and re-encrypting the vault.
class VaultCodec {
  /// Encrypts the fields of an item for sending to the server.
  /// [id] is included in the result only if provided
  /// (the update API passes it separately, add and re-encrypt do not).
  static Map<String, dynamic> encryptFields({
    String? id,
    String type = 'password',
    required String label,
    required String login,
    required String password,
    required String notes,
    required String icon,
    required String url,
    String pin = '',
    required Uint8List key,
  }) {
    final isPin = type == 'pin';
    return {
      if (id != null) 'id': id,
      'type':     type,
      'title':    CryptoService.encryptText(label, key),
      'login':    !isPin && login.isNotEmpty ? CryptoService.encryptText(login, key) : '',
      'password': !isPin ? CryptoService.encryptText(password, key) : '',
      'notes':    notes.isNotEmpty ? CryptoService.encryptText(notes, key) : '',
      'icon':     icon,
      'url':      !isPin && url.isNotEmpty ? CryptoService.encryptText(url, key) : '',
      if (!isPin) 'strength': PasswordScore.category(PasswordScore.compute(password)),
      if (isPin) 'pin': CryptoService.encryptText(pin, key),
      if (isPin) 'pin_strength': PinScore.category(PinScore.compute(pin)),
    };
  }

  /// Decrypts a raw list (from the server or the cache) into [VaultItem]s.
  /// Unreadable entries (wrong key, corrupted data) are skipped;
  /// [skipped] lets the caller tell the user that part of the vault
  /// could not be displayed, rather than silently making it
  /// disappear.
  static ({List<VaultItem> items, int skipped}) decryptRaw(List<dynamic> raw, Uint8List key) {
    final out = <VaultItem>[];
    var skipped = 0;
    for (final r in raw) {
      try {
        final type     = r['type'] as String? ?? 'password';
        final title    = CryptoService.decryptText(r['title'] as String, key);
        final rawNotes = r['notes'];
        final notes    = (rawNotes is String && rawNotes.isNotEmpty)
            ? CryptoService.decryptText(rawNotes, key)
            : '';

        if (type == 'pin') {
          out.add(VaultItem(
            id:          r['id'] as String,
            type:        'pin',
            label:       title,
            login:       '',
            password:    '',
            notes:       notes,
            pin:         CryptoService.decryptText(r['pin'] as String, key),
            pinStrength: r['pin_strength'] as String?,
          ));
          continue;
        }

        final rawLogin = r['login'];
        final login    = (rawLogin is String && rawLogin.isNotEmpty)
            ? CryptoService.decryptText(rawLogin, key)
            : '';
        final password = CryptoService.decryptText(r['password'] as String, key);
        final rawUrl = r['url'];
        final url    = (rawUrl is String && rawUrl.isNotEmpty)
            ? CryptoService.decryptText(rawUrl, key)
            : '';
        out.add(VaultItem(
          id:       r['id'] as String,
          type:     'password',
          label:    title,
          login:    login,
          password: password,
          notes:    notes,
          icon:     r['icon'] as String? ?? 'lock',
          url:      url,
        ));
      } catch (e) {
        skipped++;
        debugPrint('Decrypt error for item ${r['id']}: $e');
      }
    }
    return (items: out, skipped: skipped);
  }
}
