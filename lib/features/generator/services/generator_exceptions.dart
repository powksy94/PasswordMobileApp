/// Thrown by [PasswordGeneratorController.addToVault]/[PinGeneratorController.addToVault]
/// when the label is empty.
class MissingLabelException implements Exception {}

/// Thrown by [PasswordGenerator.generate] when no character set is
/// selected, or when the exclusions remove all of them.
class NoCharacterAvailableException implements Exception {}
