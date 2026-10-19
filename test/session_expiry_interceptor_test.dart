import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/shared/services/session_expiry_interceptor.dart';
import 'package:password_mobile_app/shared/services/session_expiry_signal.dart';

/// Answers every request with [respond], recording what was sent.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );

// A ResponseBody stream can only be read once: built anew for each request.
ResponseBody _tokenInvalid() =>
    _json(401, {'error': 'Invalid or expired token', 'code': 'TOKEN_INVALID'});

void main() {
  late Dio dio;
  late _FakeAdapter replayAdapter;
  late int signals;

  void onSignal() => signals++;

  setUp(() {
    signals = 0;
    SessionExpirySignal.notifier.addListener(onSignal);
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..interceptors.add(SessionExpiryInterceptor())
      ..httpClientAdapter = _FakeAdapter((_) => _tokenInvalid());
    replayAdapter = _FakeAdapter((_) => _json(200, {'ok': true}));
    SessionExpiryInterceptor.replayDio = Dio()..httpClientAdapter = replayAdapter;
  });

  tearDown(() {
    SessionExpirySignal.notifier.removeListener(onSignal);
    SessionExpiryInterceptor.refreshSession = null;
  });

  Future<void> expectDioError(Future<Response<dynamic>> request) async {
    try {
      await request;
      fail('expected a DioException');
    } on DioException catch (_) {}
  }

  Future<Response<dynamic>> getVault() =>
      dio.get('/vault', options: Options(headers: {'Authorization': 'Bearer old'}));

  test('refreshes the session and replays the request with the new token', () async {
    SessionExpiryInterceptor.refreshSession = () async => 'new-token';

    final res = await getVault();

    expect(res.statusCode, 200);
    expect(replayAdapter.requests.single.headers['Authorization'], 'Bearer new-token');
    expect(replayAdapter.requests.single.path, '/vault');
    expect(signals, 0);
  });

  test('raises the session expiry signal when the session is dead', () async {
    SessionExpiryInterceptor.refreshSession = () async => null;

    await expectDioError(getVault());

    expect(signals, 1);
    expect(replayAdapter.requests, isEmpty);
  });

  test('keeps the session on a network failure while refreshing', () async {
    SessionExpiryInterceptor.refreshSession = () async => throw Exception('offline');

    await expectDioError(getVault());

    expect(signals, 0);
    expect(replayAdapter.requests, isEmpty);
  });

  test('does not try to refresh on a business 401', () async {
    var refreshCalls = 0;
    SessionExpiryInterceptor.refreshSession = () async {
      refreshCalls++;
      return 'new-token';
    };
    dio.httpClientAdapter = _FakeAdapter((_) => _json(401, {'error': 'Invalid credentials'}));

    await expectDioError(getVault());

    expect(refreshCalls, 0);
    expect(signals, 0);
  });

  test('ignores other statuses, even carrying the TOKEN_INVALID code', () async {
    SessionExpiryInterceptor.refreshSession = () async => 'new-token';
    dio.httpClientAdapter =
        _FakeAdapter((_) => _json(500, {'error': 'boom', 'code': 'TOKEN_INVALID'}));

    await expectDioError(getVault());

    expect(replayAdapter.requests, isEmpty);
    expect(signals, 0);
  });

  test('raises the signal directly when no refresh is wired', () async {
    await expectDioError(getVault());

    expect(signals, 1);
  });
}
