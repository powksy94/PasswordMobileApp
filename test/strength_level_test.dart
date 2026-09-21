import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/l10n/app_localizations_en.dart';
import 'package:password_mobile_app/l10n/app_localizations_es.dart';
import 'package:password_mobile_app/l10n/app_localizations_fr.dart';
import 'package:password_mobile_app/shared/utils/strength_level.dart';

void main() {
  group('StrengthLevel.label', () {
    test('français', () {
      final l = AppLocalizationsFr();
      expect(
        StrengthLevel.values.map((s) => s.label(l)),
        ['Faible', 'Moyen', 'Fort', 'Très fort'],
      );
    });

    test('anglais', () {
      final l = AppLocalizationsEn();
      expect(
        StrengthLevel.values.map((s) => s.label(l)),
        ['Weak', 'Medium', 'Strong', 'Very strong'],
      );
    });

    test('espagnol', () {
      final l = AppLocalizationsEs();
      expect(
        StrengthLevel.values.map((s) => s.label(l)),
        ['Débil', 'Media', 'Fuerte', 'Muy fuerte'],
      );
    });
  });
}
