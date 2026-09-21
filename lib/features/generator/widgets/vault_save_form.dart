import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class VaultSaveForm extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController loginController;
  final TextEditingController notesController;
  final TextEditingController urlController;

  const VaultSaveForm({
    super.key,
    required this.labelController,
    required this.loginController,
    required this.notesController,
    required this.urlController,
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
          controller: loginController,
          decoration: InputDecoration(
            labelText:  '${l.itemLogin} ${l.labelOptional}',
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText:  '${l.itemWebsite} ${l.labelOptional}',
            hintText:   l.itemWebsiteHint,
            prefixIcon: const Icon(Icons.language),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          decoration: InputDecoration(
            labelText:  '${l.itemNotes} ${l.labelOptional}',
            prefixIcon: const Icon(Icons.notes),
          ),
        ),
      ],
    );
  }
}
