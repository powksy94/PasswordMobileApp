import 'package:dio/dio.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/utils/api_error.dart';
import '../../../l10n/app_localizations.dart';

/// "Forgot password" flow: an emailed one-time code lets the user choose a
/// new login password. Only the login password changes: the vault key
/// (master password) is never involved.
class PasswordResetService {
  static final _api = ApiService();

  static Future<void> requestCode(String email) =>
      _api.requestPasswordReset(email.trim());

  static Future<void> confirm({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _api.confirmPasswordReset(email.trim(), code.trim(), newPassword);

  /// Message for a failed [requestCode] / [confirm]: the server's reason
  /// codes get their own wording, everything else the generic HTTP one.
  static String errorMessage(AppLocalizations l, Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data   = error.response?.data;
      final code   = data is Map ? data['code'] : null;
      if (status == 429)               return l.errorTooManyRequests;
      if (code == 'INVALID_CODE')      return l.errorResetCodeInvalid;
      if (code == 'WEAK_PASSWORD')     return l.validatorPasswordComplexity;
    }
    return apiErrorMessage(l, error);
  }
}
