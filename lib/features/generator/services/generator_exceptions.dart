/// Levée par [PasswordGeneratorController.addToVault]/[PinGeneratorController.addToVault]
/// quand le label est vide.
class MissingLabelException implements Exception {}

/// Levée par [PasswordGenerator.generate] quand aucun jeu de caractères n'est
/// sélectionné, ou quand les exclusions les retirent tous.
class NoCharacterAvailableException implements Exception {}
