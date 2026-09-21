import 'package:biometric_storage/biometric_storage.dart';
import '../../../l10n/app_localizations.dart';

/// Localized texts of the system biometric prompt used for the device-encrypted
/// export/import. Provided by the caller (which has a `context`), because
/// [BiometricExportService] is a static service with no access to translations.
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
