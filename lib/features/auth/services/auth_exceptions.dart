/// Levée quand une opération qui exige une session est appelée sans token
/// stocké (session absente ou déjà fermée).
class NotAuthenticatedException implements Exception {}

/// Levée quand une opération de chiffrement/déchiffrement est appelée alors
/// que la clé maître n'est pas chargée en mémoire (coffre verrouillé).
class MasterKeyMissingException implements Exception {}

/// Levée quand le sel de dérivation du compte est absent du stockage sécurisé
/// (installation incomplète ou compte invalide).
class AccountSaltMissingException implements Exception {}
