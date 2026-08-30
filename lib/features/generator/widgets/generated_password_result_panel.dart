import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/widgets/common/password_strength_bar.dart';
import './generated_password_display.dart';
import './vault_save_form.dart';
import '../../../l10n/app_localizations.dart';

/// Bloc "résultat" affiché une fois un mot de passe généré : valeur + score
/// + formulaire de sauvegarde + bouton d'ajout. Extrait de
/// [PasswordGeneratorSection] pour que son `build()` reste court.
class GeneratedPasswordResultPanel extends StatelessWidget {
  final String       password;
  final bool         showPassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;
  final TextEditingController labelController;
  final TextEditingController loginController;
  final TextEditingController notesController;
  final TextEditingController urlController;
  final VoidCallback onAddToVault;

  const GeneratedPasswordResultPanel({
    super.key,
    required this.password,
    required this.showPassword,
    required this.onToggleVisibility,
    required this.onCopy,
    required this.labelController,
    required this.loginController,
    required this.notesController,
    required this.urlController,
    required this.onAddToVault,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        GeneratedPasswordDisplay(
          password:           password,
          showPassword:       showPassword,
          onToggleVisibility: onToggleVisibility,
          onCopy:             onCopy,
        ),
        const SizedBox(height: 8),
        PasswordStrengthBar(password: password),
        const SizedBox(height: 12),
        VaultSaveForm(
          labelController: labelController,
          loginController: loginController,
          notesController: notesController,
          urlController:   urlController,
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
