import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/l10n/app_localizations_en.dart';
import 'package:password_mobile_app/l10n/app_localizations_fr.dart';
import 'package:password_mobile_app/shared/services/session_expiry_interceptor.dart';
import 'package:password_mobile_app/shared/utils/api_error.dart';

DioException _dioError({int? status, Object? data}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: status == null ? DioExceptionType.connectionError : DioExceptionType.badResponse,
    response: status == null
        ? null
        : Response(requestOptions: req, statusCode: status, data: data),
  );
}

void main() {
  final fr = AppLocalizationsFr();
  final en = AppLocalizationsEn();

  group('apiErrorMessage', () {
    test('traduit par statut HTTP', () {
      expect(apiErrorMessage(fr, _dioError(status: 400)), fr.errorHttpBadRequest);
      expect(apiErrorMessage(fr, _dioError(status: 401)), fr.errorHttpUnauthorized);
      expect(apiErrorMessage(fr, _dioError(status: 403)), fr.errorHttpForbidden);
      expect(apiErrorMessage(fr, _dioError(status: 404)), fr.errorHttpNotFound);
      expect(apiErrorMessage(fr, _dioError(status: 409)), fr.errorHttpConflict);
      expect(apiErrorMessage(fr, _dioError(status: 422)), fr.errorHttpInvalidData);
      expect(apiErrorMessage(fr, _dioError(status: 500)), fr.errorHttpServer);
    });

    test('statut inconnu → erreur réseau avec le code', () {
      expect(apiErrorMessage(fr, _dioError(status: 418)), fr.errorHttpNetwork(418));
    });

    test('sans réponse (hors-ligne, timeout) → pas de connexion', () {
      expect(apiErrorMessage(fr, _dioError()), fr.errorNoConnection);
    });

    test("n'affiche jamais le texte anglais du serveur", () {
      final msg = apiErrorMessage(
        en,
        _dioError(status: 401, data: {'error': 'Invalid credentials'}),
      );
      expect(msg, en.errorHttpUnauthorized);
      expect(msg, isNot(contains('Invalid credentials')));
    });

    test("erreur hors Dio → message générique, sans fuite du détail", () {
      final msg = apiErrorMessage(fr, Exception('secret technique'));
      expect(msg, fr.errorUnexpected);
      expect(msg, isNot(contains('secret')));
    });
  });

  group('SessionExpiryInterceptor.isTokenRejection', () {
    test('401 TOKEN_INVALID → oui', () {
      expect(
        SessionExpiryInterceptor.isTokenRejection(
          _dioError(status: 401, data: {'code': 'TOKEN_INVALID'}),
        ),
        isTrue,
      );
    });

    test('401 métier sans code → non', () {
      expect(
        SessionExpiryInterceptor.isTokenRejection(
          _dioError(status: 401, data: {'error': 'Current password is incorrect'}),
        ),
        isFalse,
      );
    });
  });
}
