import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/widgets/common/pin_score_bar.dart';
import './generated_pin_display.dart';
import './pin_vault_save_form.dart';
import '../../../l10n/app_localizations.dart';

/// Bloc "résultat" affiché une fois un PIN généré : valeur + score +
/// formulaire de sauvegarde + bouton d'ajout. Mirroring de
/// [GeneratedPasswordResultPanel].
class GeneratedPinResultPanel extends StatelessWidget {
  final String       pin;
  final bool         showPin;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;
  final TextEditingController labelController;
  final TextEditingController notesController;
  final VoidCallback onAddToVault;

  const GeneratedPinResultPanel({
    super.key,
    required this.pin,
    required this.showPin,
    required this.onToggleVisibility,
    required this.onCopy,
    required this.labelController,
    required this.notesController,
    required this.onAddToVault,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        GeneratedPinDisplay(
          pin:                pin,
          showPin:            showPin,
          onToggleVisibility: onToggleVisibility,
          onCopy:             onCopy,
        ),
        const SizedBox(height: 8),
        PinScoreBar(pin: pin),
        const SizedBox(height: 12),
        PinVaultSaveForm(
          labelController: labelController,
          notesController: notesController,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onAddToVault,
          icon:  const FaIcon(FontAwesomeIcons.vault),
          label: Text(l.btnAddToVault),
        ),
      ],
    );
  }
}
