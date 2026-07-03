/// Levée par [VaultService.changeMasterPassword] quand l'ancien mot de passe
/// maître saisi ne correspond pas à celui actuellement utilisé.
class WrongMasterPasswordException implements Exception {}

/// Levée par [VaultService.changeMasterPassword] quand l'envoi du coffre
/// re-chiffré échoue. Le serveur traite la mise à jour comme une transaction
/// tout-ou-rien : en cas d'erreur, aucune écriture n'est appliquée et le coffre
/// reste intact avec l'ancien chiffrement (la nouvelle clé n'est pas persistée).
class MasterPasswordChangeException implements Exception {
  final Object cause;
  MasterPasswordChangeException(this.cause);
}

/// Levée par [VaultService.loadFromServer] quand le serveur retourne des items
/// mais qu'aucun ne peut être déchiffré — indique un mot de passe maître incorrect.
class VaultDecryptionException implements Exception {
  const VaultDecryptionException();
}
