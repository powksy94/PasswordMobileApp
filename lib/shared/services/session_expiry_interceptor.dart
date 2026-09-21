import 'package:dio/dio.dart';
import './session_expiry_signal.dart';

/// Lève [SessionExpirySignal] sur les 401 marqués `TOKEN_INVALID` par le
/// serveur (middleware d'authentification). Les autres 401 (ex. mauvais mot
/// de passe actuel au changement de mot de passe, identifiants de login
/// incorrects) ne portent pas ce code et restent de simples erreurs métier.
class SessionExpiryInterceptor extends Interceptor {
  static const _tokenInvalidCode = 'TOKEN_INVALID';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (err.response?.statusCode == 401 &&
        data is Map &&
        data['code'] == _tokenInvalidCode) {
      SessionExpirySignal.raise();
    }
    handler.next(err);
  }
}
