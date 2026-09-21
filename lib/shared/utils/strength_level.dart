import '../../l10n/app_localizations.dart';

/// Niveau de robustesse d'un secret, indépendant de la langue. Les scores
/// ([PasswordScore], [PinScore]) le calculent ; l'affichage le traduit via
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
