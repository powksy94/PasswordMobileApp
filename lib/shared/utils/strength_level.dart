import '../../l10n/app_localizations.dart';

/// Strength level of a secret, independent of the language. The scores
/// ([PasswordScore], [PinScore]) compute it; the UI translates it via
/// [StrengthLevelLabel.label].
enum StrengthLevel { weak, medium, strong, veryStrong }

extension StrengthLevelLabel on StrengthLevel {
  String label(AppLocalizations l) => switch (this) {
        StrengthLevel.weak       => l.strengthWeak,
        StrengthLevel.medium     => l.strengthMedium,
        StrengthLevel.strong     => l.strengthStrong,
        StrengthLevel.veryStrong => l.strengthVeryStrong,
      };
}
