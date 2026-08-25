import 'dart:convert';
import 'dart:typed_data';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './biometric_service.dart';

/// Stocke une copie de la clé maître dans le Keystore Android / Secure
/// Enclave iOS (`biometric_storage`), pour que le déverrouillage biométrique
/// soit garanti par le matériel plutôt que par un simple booléen applicatif
/// (voir `upgrade/BIOMETRIC_UNLOCK_HARDENING.md`). Store distinct de celui
/// utilisé par `biometric_export_service.dart` pour l'export.
///
/// Ne connaît rien de [MasterKeyService] : chaque appelant lui fournit la
/// clé à protéger et récupère celle déverrouillée en retour.
class BiometricUnlockService {
  static const _storeName = 'vault_unlock_key_v1';

  // Suivi (sans prompt) de l'état de provisionnement : évite d'avoir à lire
  // le store — ce qui déclencherait un prompt — juste pour savoir s'il
  // contient déjà quelque chose.
  static const _prefProvisioned = 'biometric_unlock_key_provisioned';

  // ── Lecture ───────────────────────────────────────────────────────────────────

  /// Lit la clé (déclenche le prompt biométrique matériel). `null` en cas
  /// d'annulation, d'échec ou de clé absente/invalidée — l'appelant doit
  /// alors proposer le déverrouillage par mot de passe.
  static Future<Uint8List?> unlock({
    required String promptTitle,
    required String cancelLabel,
  }) async {
    try {
      final store  = await _storage();
      final stored = await store.read(promptInfo: _promptInfo(promptTitle, cancelLabel));
      if (stored == null) return null;
      return Uint8List.fromList(base64Decode(stored));
    } on AuthException catch (e) {
      if (e.code == AuthExceptionCode.userCanceled || e.code == AuthExceptionCode.canceled) {
        return null;
      }
      // Erreur inattendue (ex. clé invalidée après changement d'empreintes
      // enregistrées sur l'appareil) : on nettoie pour éviter d'échouer
      // indéfiniment plutôt que de re-proposer une biométrie cassée.
      await disable();
      return null;
    } catch (_) {
      await disable();
      return null;
    }
  }

  // ── Écriture ──────────────────────────────────────────────────────────────────

  /// Écrit [key] dans le store protégé par biométrie (déclenche un prompt).
  /// Retourne `false` (sans relancer d'exception) en cas d'annulation ou
  /// d'échec : l'activation de la biométrie ne doit jamais faire échouer
  /// l'opération qui l'a déclenchée (connexion, changement de mot de passe
  /// maître…), qui a déjà réussi à ce stade.
  static Future<bool> enable(
    Uint8List key, {
    required String promptTitle,
    required String cancelLabel,
  }) async {
    try {
      final store = await _storage();
      await store.write(
        base64Encode(key),
        promptInfo: _promptInfo(promptTitle, cancelLabel),
      );
      await _setProvisioned(true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Supprime la clé. Aucun prompt (suppression de fichier, pas d'opération
  /// cryptographique côté plugin natif).
  static Future<void> disable() async {
    try {
      final store = await _storage();
      await store.delete();
    } catch (_) {
      // Rien à supprimer ou store jamais initialisé — sans conséquence.
    }
    await _setProvisioned(false);
  }

  // ── Scénarios d'appel ─────────────────────────────────────────────────────────

  /// À appeler juste après une connexion/inscription réussie, avec la clé
  /// maître qui vient d'être dérivée. Si la biométrie est activée (réglages)
  /// et disponible, mais jamais encore provisionnée sur cet appareil,
  /// l'active — un seul prompt, une seule fois, jamais répété aux
  /// connexions suivantes.
  static Future<void> maybeAutoEnable(
    Uint8List key, {
    required bool biometricEnabledSetting,
    required String promptTitle,
    required String cancelLabel,
  }) async {
    if (!biometricEnabledSetting) return;
    if (await isProvisioned()) return;
    if (!await BiometricService.isAvailable()) return;
    await enable(key, promptTitle: promptTitle, cancelLabel: cancelLabel);
  }

  /// À appeler après un changement de mot de passe maître / reset du vault,
  /// avec la nouvelle clé : si la biométrie était déjà provisionnée, la
  /// remet à jour (sinon l'ancienne copie chiffrerait encore l'ancienne
  /// clé). Ne fait rien si elle n'était pas activée — pas de prompt surprise.
  ///
  /// Si l'utilisateur annule ce prompt, on désactive plutôt que de laisser
  /// une clé désormais périmée dans le store : un futur déverrouillage
  /// biométrique la lirait "avec succès" mais renverrait l'ANCIENNE clé,
  /// corrompant silencieusement le déchiffrement du coffre au lieu de
  /// simplement retomber sur le mot de passe.
  static Future<void> resyncAfterKeyChange(
    Uint8List key, {
    required String promptTitle,
    required String cancelLabel,
  }) async {
    if (!await isProvisioned()) return;
    final success = await enable(key, promptTitle: promptTitle, cancelLabel: cancelLabel);
    if (!success) await disable();
  }

  // ── État ──────────────────────────────────────────────────────────────────────

  static Future<bool> isProvisioned() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefProvisioned) ?? false;
  }

  static Future<void> _setProvisioned(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefProvisioned, value);
  }

  // ── Bas niveau ────────────────────────────────────────────────────────────────

  static Future<BiometricStorageFile> _storage() {
    return BiometricStorage().getStorage(
      _storeName,
      options: StorageFileInitOptions(
        authenticationRequired: true,
        // -1 = toujours redemander la biométrie, pas de fenêtre de validité.
        authenticationValidityDurationSeconds: -1,
        androidBiometricOnly: true,
      ),
    );
  }

  static PromptInfo _promptInfo(String title, String cancelLabel) => PromptInfo(
        androidPromptInfo: AndroidPromptInfo(title: title, negativeButton: cancelLabel),
        iosPromptInfo: IosPromptInfo(saveTitle: title, accessTitle: title),
      );
}
