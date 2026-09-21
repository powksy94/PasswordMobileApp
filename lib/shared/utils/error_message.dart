import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/services/auth_exceptions.dart';
import '../../features/generator/services/generator_exceptions.dart';
import '../../features/vault/services/vault_exceptions.dart';
import '../../l10n/app_localizations.dart';
import './api_error.dart';

/// Single conversion point "error -> displayable message". Every page that
/// shows an error to the user goes through here instead of displaying
/// `'$e'`: known exceptions are translated, the others become a generic
/// message (their technical detail goes to the log, never to the screen).
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

  debugPrint('[errorMessage] untranslated error: $error');
  return l.errorUnexpected;
}
