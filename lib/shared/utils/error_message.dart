import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/services/auth_exceptions.dart';
import '../../features/generator/services/generator_exceptions.dart';
import '../../features/vault/services/vault_exceptions.dart';
import '../../l10n/app_localizations.dart';
import './api_error.dart';

/// Point de conversion unique « erreur → message affichable ». Toute page qui
/// montre une erreur à l'utilisateur passe par ici plutôt que d'afficher
/// `'$e'` : les exceptions connues sont traduites, les autres deviennent un
/// message générique (leur détail technique va au log, jamais à l'écran).
String errorMessage(AppLocalizations l, Object error) {
  if (error is DioException)                  return apiErrorMessage(l, error);
  if (error is NotAuthenticatedException)     return l.errorNotAuthenticated;
  if (error is MasterKeyMissingException)     return l.errorMasterKeyMissing;
  if (error is AccountSaltMissingException)   return l.errorAccountSaltMissing;
  if (error is NoCharacterAvailableException) return l.errorGeneratorNoCharset;
  if (error is MissingLabelException)         return l.errorLabelMissing;
  if (error is VaultDecryptionException)      return l.errorVaultDecryptionFailed;
  if (error is WrongMasterPasswordException)  return l.errorWrongMasterPassword;
  if (error is MasterPasswordChangeException) return l.errorMasterPasswordChangeFailed;

  debugPrint('[errorMessage] erreur non traduite : $error');
  return l.errorUnexpected;
}
