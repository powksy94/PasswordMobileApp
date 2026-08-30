import 'package:flutter/material.dart';
import '../widgets/generator_type_selector.dart';
import '../widgets/password_generator_section.dart';
import '../widgets/pin_generator_section.dart';

/// Switcher entre le générateur de mots de passe et de PINs — même API
/// publique qu'avant (onVaultUpdated) : aucun changement dans home_page.dart.
class PasswordGeneratorPage extends StatefulWidget {
  final VoidCallback? onVaultUpdated;

  const PasswordGeneratorPage({super.key, this.onVaultUpdated});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  String _selectedType = 'password';

  // ── Build — pas de Scaffold (géré par HomePage) ──────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GeneratorTypeSelector(
            selected:  _selectedType,
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedType == 'pin'
                ? PinGeneratorSection(onVaultUpdated: widget.onVaultUpdated)
                : PasswordGeneratorSection(onVaultUpdated: widget.onVaultUpdated),
          ),
        ],
      ),
    );
  }
}
