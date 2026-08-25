import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../shared/widgets/common/pin_score_bar.dart';
import '../../../l10n/app_localizations.dart';

/// Formulaire commun à l'ajout et à la modification d'un PIN (label, PIN,
/// notes) — pendant minimal de [VaultItemForm], sans login/url/icône.
class PinItemForm extends StatelessWidget {
  final TextEditingController labelCtrl;
  final TextEditingController pinCtrl;
  final TextEditingController notesCtrl;
  final bool showPin;
  final VoidCallback onTogglePinVisibility;
  final VoidCallback onPinChanged;

  const PinItemForm({
    super.key,
    required this.labelCtrl,
    required this.pinCtrl,
    required this.notesCtrl,
    required this.showPin,
    required this.onTogglePinVisibility,
    required this.onPinChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: labelCtrl,
            decoration: InputDecoration(
              labelText:  l.itemLabel,
              prefixIcon: const Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller:   pinCtrl,
            obscureText:  !showPin,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged:    (_) => onPinChanged(),
            decoration: InputDecoration(
              labelText:  l.itemPin,
              prefixIcon: const Icon(Icons.pin_outlined),
              suffixIcon: IconButton(
                icon: Icon(showPin ? Icons.visibility_off : Icons.visibility),
                onPressed: onTogglePinVisibility,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PinScoreBar(pin: pinCtrl.text),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
            maxLines:   3,
            decoration: InputDecoration(
              labelText:          l.itemNotes,
              prefixIcon:         const Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
