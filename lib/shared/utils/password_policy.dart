import '../../l10n/app_localizations.dart';

/// Règle unique de robustesse appliquée partout où un mot de passe (compte ou
/// maître) est créé ou modifié : inscription, changement de mot de passe,
/// changement/réinitialisation du mot de passe maître. Ne s'applique pas au
/// formulaire de connexion, qui valide un identifiant déjà existant et ne doit
/// pas bloquer un compte créé sous une règle antérieure.
class PasswordPolicy {
  static const int minLength = 12;

  static bool hasLower(String v)   => RegExp(r'[a-z]').hasMatch(v);
  static bool hasUpper(String v)   => RegExp(r'[A-Z]').hasMatch(v);
  static bool hasDigit(String v)   => RegExp(r'[0-9]').hasMatch(v);
  static bool hasSpecial(String v) => RegExp(r'[^a-zA-Z0-9]').hasMatch(v);

  static bool meetsComplexity(String v) =>
      hasLower(v) && hasUpper(v) && hasDigit(v) && hasSpecial(v);

  static bool isValid(String v) => v.length >= minLength && meetsComplexity(v);

  /// Utilisable directement comme `TextFormField.validator`.
  static String? validator(String? v, AppLocalizations l) {
    if (v == null || v.length < minLength) return l.validatorMinChars;
    if (!meetsComplexity(v)) return l.validatorPasswordComplexity;
    return null;
  }
}
