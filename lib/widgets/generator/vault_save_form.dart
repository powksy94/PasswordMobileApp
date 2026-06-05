import 'package:flutter/material.dart';

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
    return Column(
      children: [
        TextField(
          controller: labelController,
          decoration: const InputDecoration(
            labelText:  'Label du mot de passe',
            prefixIcon: Icon(Icons.label_outline),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: loginController,
          decoration: const InputDecoration(
            labelText:  'Login / Email (optionnel)',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText:  'Site web (optionnel)',
            hintText:   'ex: amazon.fr',
            prefixIcon: Icon(Icons.language),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText:  'Notes (optionnel)',
            prefixIcon: Icon(Icons.notes),
          ),
        ),
      ],
    );
  }
}
