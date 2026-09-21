import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/auth/services/auth_exceptions.dart';
import 'package:password_mobile_app/features/generator/services/generator_exceptions.dart';
import 'package:password_mobile_app/features/generator/services/password_generator.dart';
import 'package:password_mobile_app/features/vault/services/vault_exceptions.dart';
import 'package:password_mobile_app/l10n/app_localizations_en.dart';
import 'package:password_mobile_app/l10n/app_localizations_es.dart';
import 'package:password_mobile_app/l10n/app_localizations_fr.dart';
import 'package:password_mobile_app/shared/utils/error_message.dart';

void main() {
  final fr = AppLocalizationsFr();

  group('errorMessage', () {
    test('exceptions typées connues → message localisé', () {
      expect(errorMessage(fr, NotAuthenticatedException()), fr.errorNotAuthenticated);
      expect(errorMessage(fr, MasterKeyMissingException()), fr.errorMasterKeyMissing);
      expect(errorMessage(fr, AccountSaltMissingException()), fr.errorAccountSaltMissing);
      expect(errorMessage(fr, NoCharacterAvailableException()), fr.errorGeneratorNoCharset);
      expect(errorMessage(fr, MissingLabelException()), fr.errorLabelMissing);
      expect(errorMessage(fr, const VaultDecryptionException()), fr.errorVaultDecryptionFailed);
      expect(errorMessage(fr, WrongMasterPasswordException()), fr.errorWrongMasterPassword);
      expect(
        errorMessage(fr, MasterPasswordChangeException('cause')),
        fr.errorMasterPasswordChangeFailed,
      );
    });

    test('DioException → message par statut', () {
      final req = RequestOptions(path: '/x');
      final err = DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 409),
      );
      expect(errorMessage(fr, err), fr.errorHttpConflict);
    });

    test("exception inconnue → message générique, sans fuite du texte technique", () {
      final msg = errorMessage(fr, Exception('Non authentifié brut'));
      expect(msg, fr.errorUnexpected);
      expect(msg, isNot(contains('Exception')));
      expect(msg, isNot(contains('brut')));
    });

    test('aucun jeu de caractères → NoCharacterAvailableException (générateur)', () {
      expect(
        () => PasswordGenerator.generate(
          useLower: false, useUpper: false, useDigits: false, useSpecials: false,
        ),
        throwsA(isA<NoCharacterAvailableException>()),
      );
    });
  });

  group('messages du lot : pas de tiret cadratin', () {
    test('fr / en / es', () {
      for (final l in [AppLocalizationsFr(), AppLocalizationsEn(), AppLocalizationsEs()]) {
        final texts = [
          l.errorNotAuthenticated, l.errorMasterKeyMissing, l.errorAccountSaltMissing,
          l.errorGeneratorNoCharset, l.errorUnexpected, l.exportBiometricTitle,
          l.exportBiometricSubtitle, l.errorNoConnection, l.errorHttpServer, l.offlineBanner,
        ];
        for (final t in texts) {
          expect(t, isNot(contains('—')), reason: t);
        }
      }
    });
  });
}
