/// Thrown by [VaultReencryptService.changeMasterPassword] when the old master
/// password entered does not match the one currently in use.
class WrongMasterPasswordException implements Exception {}

/// Thrown by [VaultReencryptService.changeMasterPassword] when sending the re-encrypted
/// vault fails. The server treats the update as an all-or-nothing
/// transaction: on error, no write is applied and the vault
/// stays intact with the old encryption (the new key is not persisted).
class MasterPasswordChangeException implements Exception {
  final Object cause;
  MasterPasswordChangeException(this.cause);
}

/// Thrown by [VaultService.loadFromServer] when the server returns items
/// but none can be decrypted: indicates an incorrect master password.
class VaultDecryptionException implements Exception {
  const VaultDecryptionException();
}
