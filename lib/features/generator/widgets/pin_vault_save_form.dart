import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// Mirroring réduit de [VaultSaveForm] pour un PIN : pas de login/url, comme
/// [PinItemForm].
class PinVaultSaveForm extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController notesController;

  const PinVaultSaveForm({
    super.key,
    required this.labelController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextField(
          controller: labelController,
          decoration: InputDecoration(
            labelText:  l.itemLabel,
            prefixIcon: const Icon(Icons.label_outline),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          decoration: InputDecoration(
            labelText:  l.itemNotes,
            prefixIcon: const Icon(Icons.notes),
          ),
        ),
      ],
    );
  }
}
