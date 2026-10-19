import 'package:dio/dio.dart';
import '../../../shared/services/api_service.dart';
import './auth_service.dart';

/// Silently renews the access token with the stored refresh token (rotated
/// on every use by the server). Wired into [SessionExpiryInterceptor] from
/// main.dart, so the network layer stays unaware of authentication.
class SessionRefreshService {
  static final _api = ApiService();

  /// Shared by every request rejected at the same time: the refresh token
  /// is single-use, two parallel refreshes would make the second one look
  /// like a stolen-token reuse server-side.
  static Future<String?>? _inFlight;

  /// The new access token, or `null` if the session is dead (no refresh
  /// token, or rejected by the server): the user must log in again.
  /// Throws on network failure: the session is kept, to retry later.
  static Future<String?> refresh() =>
      _inFlight ??= _refresh().whenComplete(() => _inFlight = null);

  static Future<String?> _refresh() async {
    final refreshToken = await AuthService.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final res = await _api.refreshSession(refreshToken);
      final token = res['token'] as String;
      await AuthService.saveSession(
        token:        token,
        refreshToken: res['refreshToken'] as String?,
        role:         res['role'] as String? ?? 'user',
      );
      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      rethrow;
    }
  }
}
