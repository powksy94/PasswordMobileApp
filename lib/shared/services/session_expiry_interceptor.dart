import 'package:dio/dio.dart';
import './session_expiry_signal.dart';

/// Raises [SessionExpirySignal] on 401s marked `TOKEN_INVALID` by the
/// server (authentication middleware). Other 401s (e.g. wrong current
/// password on password change, incorrect login credentials) do not carry
/// this code and remain plain business errors.
class SessionExpiryInterceptor extends Interceptor {
  static const _tokenInvalidCode = 'TOKEN_INVALID';

  /// True if [err] is a rejection of the session token (as opposed to any
  /// other business 401). Lets screens ignore this error: the
  /// session handler already takes care of it.
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
