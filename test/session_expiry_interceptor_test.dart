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
    // expected: statuses >= 400 throw
  }
}

void main() {
  group('SessionExpiryInterceptor', () {
    test('raises the signal on a 401 TOKEN_INVALID', () async {
      final before = SessionExpirySignal.notifier.value;
      await _request(401, {'error': 'Invalid or expired token', 'code': 'TOKEN_INVALID'});
      expect(SessionExpirySignal.notifier.value, before + 1);
    });

    test('ignores a business 401 without a code (wrong current password)', () async {
      final before = SessionExpirySignal.notifier.value;
      await _request(401, {'error': 'Current password is incorrect'});
      expect(SessionExpirySignal.notifier.value, before);
    });

    test('ignores other statuses', () async {
      final before = SessionExpirySignal.notifier.value;
      await _request(500, {'error': 'boom', 'code': 'TOKEN_INVALID'});
      expect(SessionExpirySignal.notifier.value, before);
    });
  });
}
