import 'package:dio/dio.dart';
import './session_expiry_signal.dart';

/// Lève [SessionExpirySignal] sur les 401 marqués `TOKEN_INVALID` par le
/// serveur (middleware d'authentification). Les autres 401 (ex. mauvais mot
/// de passe actuel au changement de mot de passe, identifiants de login
/// incorrects) ne portent pas ce code et restent de simples erreurs métier.
class SessionExpiryInterceptor extends Interceptor {
  static const _tokenInvalidCode = 'TOKEN_INVALID';

  /// Vrai si [err] est un rejet du token de session (par opposition à un
  /// autre 401 métier). Permet aux écrans d'ignorer cette erreur : le
  /// gestionnaire de session s'en charge déjà.
  static bool isTokenRejection(DioException err) {
    final data = err.response?.data;
    return err.response?.statusCode == 401 &&
        data is Map &&
        data['code'] == _tokenInvalidCode;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isTokenRejection(err)) SessionExpirySignal.raise();
    handler.next(err);
  }
}
