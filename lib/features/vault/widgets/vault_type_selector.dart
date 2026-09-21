import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// "Passwords / PINs" selector at the top of [VaultPage], following the same
/// composition pattern as [OfflineBanner]/[VaultSearchBar]: a small
/// dedicated widget rather than inlined in the page.
class VaultTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const VaultTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(value: 'password', label: Text(l.tabPasswords)),
          ButtonSegment(value: 'pin',      label: Text(l.tabPins)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
