import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/services/session_expiry_interceptor.dart';
import 'package:password_mobile_app/shared/services/session_expiry_signal.dart';

class _StubAdapter implements HttpClientAdapter {
  final int status;
  final Map<String, dynamic> body;
  _StubAdapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );

  @override
  void close({bool force = false}) {}
}

Future<void> _request(int status, Map<String, dynamic> body) async {
  final dio = Dio()
    ..httpClientAdapter = _StubAdapter(status, body)
    ..interceptors.add(SessionExpiryInterceptor());
  try {
    await dio.get('https://example.test/x');
  } on DioException {
    // attendu : les statuts >= 400 lèvent
  }
}

void main() {
  group('SessionExpiryInterceptor', () {
    test('lève le signal sur un 401 TOKEN_INVALID', () async {
      final before = SessionExpirySignal.notifier.value;
      await _request(401, {'error': 'Invalid or expired token', 'code': 'TOKEN_INVALID'});
      expect(SessionExpirySignal.notifier.value, before + 1);
    });

    test('ignore un 401 métier sans code (mauvais mot de passe actuel)', () async {
      final before = SessionExpirySignal.notifier.value;
      await _request(401, {'error': 'Current password is incorrect'});
      expect(SessionExpirySignal.notifier.value, before);
    });

    test('ignore les autres statuts', () async {
      final before = SessionExpirySignal.notifier.value;
      await _request(500, {'error': 'boom', 'code': 'TOKEN_INVALID'});
      expect(SessionExpirySignal.notifier.value, before);
    });
  });
}
