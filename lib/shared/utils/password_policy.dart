import '../../l10n/app_localizations.dart';

/// Single strength rule applied wherever a password (account or
/// master) is created or changed: signup, password change,
/// master password change/reset. Does not apply to the
/// login form, which validates an already existing credential and must not
/// block an account created under an earlier rule.
class PasswordPolicy {
  static const int minLength = 12;

  static bool hasLower(String v)   => RegExp(r'[a-z]').hasMatch(v);
  static bool hasUpper(String v)   => RegExp(r'[A-Z]').hasMatch(v);
  static bool hasDigit(String v)   => RegExp(r'[0-9]').hasMatch(v);
  static bool hasSpecial(String v) => RegExp(r'[^a-zA-Z0-9]').hasMatch(v);

  static bool meetsComplexity(String v) =>
      hasLower(v) && hasUpper(v) && hasDigit(v) && hasSpecial(v);

  static bool isValid(String v) => v.length >= minLength && meetsComplexity(v);

  /// Usable directly as `TextFormField.validator`.
  static String? validator(String? v, AppLocalizations l) {
    if (v == null || v.length < minLength) return l.validatorMinChars;
    if (!meetsComplexity(v)) return l.validatorPasswordComplexity;
    return null;
  }
}
