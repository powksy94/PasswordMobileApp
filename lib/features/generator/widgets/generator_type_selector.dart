import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// "Passwords / PINs" selector at the top of the Generator page, same
/// pattern as VaultTypeSelector.
class GeneratorTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const GeneratorTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'password', label: Text(l.tabPasswords)),
        ButtonSegment(value: 'pin',      label: Text(l.tabPins)),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
