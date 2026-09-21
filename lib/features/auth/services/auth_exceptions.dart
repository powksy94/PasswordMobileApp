/// Thrown when an operation that requires a session is called without a stored
/// token (missing or already closed session).
class NotAuthenticatedException implements Exception {}

/// Thrown when an encryption/decryption operation is called while
/// the master key is not loaded in memory (locked vault).
class MasterKeyMissingException implements Exception {}

/// Thrown when the account derivation salt is missing from secure storage
/// (incomplete install or invalid account).
class AccountSaltMissingException implements Exception {}
