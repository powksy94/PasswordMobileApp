import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import './session_expiry_signal.dart';

/// On 401s marked `TOKEN_INVALID` by the server (authentication
/// middleware), first tries to renew the session through [refreshSession]
/// and replays the request; raises [SessionExpirySignal] only when the
/// session cannot be renewed. Other 401s (e.g. wrong current password on
/// password change, incorrect login credentials) do not carry this code
/// and remain plain business errors.
class SessionExpiryInterceptor extends Interceptor {
  static const _tokenInvalidCode = 'TOKEN_INVALID';
  static const _retriedKey       = 'session_retried';

  /// Returns a new access token, `null` if the session is dead, throws on
  /// network failure. Set from main.dart (SessionRefreshService) so this
  /// layer knows nothing about authentication storage.
  static Future<String?> Function()? refreshSession;

  // Replays without this interceptor: a replay rejected again must not
  // trigger another refresh.
  @visibleForTesting
  static Dio replayDio = Dio();

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
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!isTokenRejection(err)) return handler.next(err);

    final options = err.requestOptions;
    final refresh = refreshSession;
    if (refresh == null || options.extra[_retriedKey] == true) {
      SessionExpirySignal.raise();
      return handler.next(err);
    }

    final String? newToken;
    try {
      newToken = await refresh();
    } catch (_) {
      // Network failure while refreshing: keep the session, fail this call.
      return handler.next(err);
    }
    if (newToken == null) {
      SessionExpirySignal.raise();
      return handler.next(err);
    }

    options.headers['Authorization'] = 'Bearer $newToken';
    options.extra[_retriedKey] = true;
    try {
      handler.resolve(await replayDio.fetch(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
