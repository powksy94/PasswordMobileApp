import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/l10n/app_localizations_en.dart';
import 'package:password_mobile_app/l10n/app_localizations_es.dart';
import 'package:password_mobile_app/l10n/app_localizations_fr.dart';
import 'package:password_mobile_app/shared/utils/strength_level.dart';

void main() {
  group('StrengthLevel.label', () {
    test('French', () {
      final l = AppLocalizationsFr();
      expect(
        StrengthLevel.values.map((s) => s.label(l)),
        ['Faible', 'Moyen', 'Fort', 'Très fort'],
      );
    });

    test('English', () {
      final l = AppLocalizationsEn();
      expect(
        StrengthLevel.values.map((s) => s.label(l)),
        ['Weak', 'Medium', 'Strong', 'Very strong'],
      );
    });

    test('Spanish', () {
      final l = AppLocalizationsEs();
      expect(
        StrengthLevel.values.map((s) => s.label(l)),
        ['Débil', 'Media', 'Fuerte', 'Muy fuerte'],
      );
    });
  });
}
