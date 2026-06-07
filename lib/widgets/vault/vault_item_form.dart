import 'package:flutter/material.dart';
import '../common/glass_panel.dart';
import '../common/password_strength_bar.dart';
import 'icon_selector.dart';
import '../../l10n/app_localizations.dart';

/// Formulaire commun à l'ajout et à la modification d'un item du coffre
/// (label, login, mot de passe, site web, notes, icône).
class VaultItemForm extends StatelessWidget {
  final TextEditingController labelCtrl;
  final TextEditingController loginCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController urlCtrl;
  final TextEditingController notesCtrl;
  final String selectedIcon;
  final ValueChanged<String> onIconChanged;
  final bool showPassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onPasswordChanged;

  const VaultItemForm({
    super.key,
    required this.labelCtrl,
    required this.loginCtrl,
    required this.passwordCtrl,
    required this.urlCtrl,
    required this.notesCtrl,
    required this.selectedIcon,
    required this.onIconChanged,
    required this.showPassword,
    required this.onTogglePasswordVisibility,
    required this.onPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            controller: loginCtrl,
            decoration: InputDecoration(
              labelText:  l.itemLogin,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller:  passwordCtrl,
            obscureText: !showPassword,
            onChanged:   (_) => onPasswordChanged(),
            decoration: InputDecoration(
              labelText:  l.itemPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: onTogglePasswordVisibility,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PasswordStrengthBar(password: passwordCtrl.text),
          const SizedBox(height: 12),
          TextField(
            controller:   urlCtrl,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText:  l.itemWebsite,
              hintText:   l.itemWebsiteHint,
              prefixIcon: const Icon(Icons.language),
            ),
          ),
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
          const SizedBox(height: 16),
          Text(
            l.itemIcon,
            style: TextStyle(
              color:    isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          IconSelector(selected: selectedIcon, onChanged: onIconChanged),
        ],
      ),
    );
  }
}
