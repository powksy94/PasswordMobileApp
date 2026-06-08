import 'package:flutter/foundation.dart';
import '../../../shared/services/crypto_service.dart';
import '../../../shared/utils/password_score.dart';
import '../models/vault_item.dart';

/// Convertit les [VaultItem] vers/depuis leur représentation chiffrée
/// échangée avec le serveur. Centralise la logique de chiffrement/déchiffrement
/// des champs, partagée par l'ajout, la modification et le re-chiffrement du coffre.
class VaultCodec {
  /// Chiffre les champs d'un item pour l'envoi au serveur.
  /// [id] est inclus dans le résultat seulement s'il est fourni
  /// (l'API d'update le passe séparément, l'ajout et le re-chiffrement non).
  static Map<String, dynamic> encryptFields({
    String? id,
    required String label,
    required String login,
    required String password,
    required String notes,
    required String icon,
    required String url,
    required Uint8List key,
  }) {
    return {
      if (id != null) 'id': id,
      'title':    CryptoService.encryptText(label, key),
      'login':    login.isNotEmpty ? CryptoService.encryptText(login, key) : '',
      'password': CryptoService.encryptText(password, key),
      'notes':    notes.isNotEmpty ? CryptoService.encryptText(notes, key) : '',
      'icon':     icon,
      'url':      url.isNotEmpty ? CryptoService.encryptText(url, key) : '',
      'strength': PasswordScore.category(PasswordScore.compute(password)),
    };
  }

  /// Déchiffre une liste brute (issue du serveur ou du cache) en [VaultItem].
  /// Les entrées illisibles (clé incorrecte, données corrompues) sont ignorées.
  static List<VaultItem> decryptRaw(List<dynamic> raw, Uint8List key) {
    final out = <VaultItem>[];
    for (final r in raw) {
      try {
        final title    = CryptoService.decryptText(r['title'] as String, key);
        final rawLogin = r['login'];
        final login    = (rawLogin is String && rawLogin.isNotEmpty)
            ? CryptoService.decryptText(rawLogin, key)
            : '';
        final password = CryptoService.decryptText(r['password'] as String, key);
        final rawNotes = r['notes'];
        final notes    = (rawNotes is String && rawNotes.isNotEmpty)
            ? CryptoService.decryptText(rawNotes, key)
            : '';
        final rawUrl = r['url'];
        final url    = (rawUrl is String && rawUrl.isNotEmpty)
            ? CryptoService.decryptText(rawUrl, key)
            : '';
        out.add(VaultItem(
          id:       r['id'] as String,
          label:    title,
          login:    login,
          password: password,
          notes:    notes,
          icon:     r['icon'] as String? ?? 'lock',
          url:      url,
        ));
      } catch (e) {
        debugPrint('Erreur decrypt item ${r['id']}: $e');
      }
    }
    return out;
  }
}
