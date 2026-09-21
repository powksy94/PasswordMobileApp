import 'package:dio/dio.dart';
import '../../l10n/app_localizations.dart';

/// Message localisé pour une erreur d'appel API, déduit du seul code de
/// statut HTTP : le texte renvoyé par le serveur (anglais, non traduit) n'est
/// volontairement jamais affiché. Hors [DioException], l'erreur est
/// inattendue — on ne montre pas son détail technique à l'utilisateur.
String apiErrorMessage(AppLocalizations l, Object error) {
  if (error is! DioException) return l.errorUnexpected;

  final status = error.response?.statusCode;
  if (status == null) return l.errorNoConnection; // timeout, hors-ligne, DNS…

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
