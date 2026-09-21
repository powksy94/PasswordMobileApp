import 'package:biometric_storage/biometric_storage.dart';
import '../../../l10n/app_localizations.dart';

/// Textes localisés du prompt biométrique système utilisé pour l'export/import
/// chiffré par l'appareil. Fournis par l'appelant (qui a un `context`), car
/// [BiometricExportService] est un service statique sans accès aux traductions.
class BiometricPromptTexts {
  final String title;
  final String subtitle;
  final String cancelLabel;

  const BiometricPromptTexts({
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
  });

  factory BiometricPromptTexts.forExport(AppLocalizations l) => BiometricPromptTexts(
        title:       l.exportBiometricTitle,
        subtitle:    l.exportBiometricSubtitle,
        cancelLabel: l.btnCancel,
      );

  PromptInfo toPromptInfo() => PromptInfo(
        androidPromptInfo: AndroidPromptInfo(
          title:          title,
          subtitle:       subtitle,
          negativeButton: cancelLabel,
        ),
        iosPromptInfo: IosPromptInfo(saveTitle: title, accessTitle: title),
      );
}
