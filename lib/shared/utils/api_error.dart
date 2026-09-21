import 'package:dio/dio.dart';
import '../../l10n/app_localizations.dart';

/// Localized message for an API call error, derived only from the HTTP
/// status code: the text returned by the server (English, untranslated) is
/// deliberately never displayed. Outside [DioException], the error is
/// unexpected: its technical detail is not shown to the user.
String apiErrorMessage(AppLocalizations l, Object error) {
  if (error is! DioException) return l.errorUnexpected;

  final status = error.response?.statusCode;
  if (status == null) return l.errorNoConnection; // timeout, offline, DNS...

  switch (status) {
    case 400: return l.errorHttpBadRequest;
    case 401: return l.errorHttpUnauthorized;
    case 403: return l.errorHttpForbidden;
    case 404: return l.errorHttpNotFound;
    case 409: return l.errorHttpConflict;
    case 422: return l.errorHttpInvalidData;
    case 500: return l.errorHttpServer;
    default:  return l.errorHttpNetwork(status);
  }
}
