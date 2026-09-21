import 'package:flutter/material.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../l10n/app_localizations.dart';

/// PIN length choice: 4 or 6 only (see PIN_VAULT_SPEC.md:
/// no free length for a PIN, unlike the password).
class PinGeneratorControls extends StatelessWidget {
  final int length;
  final ValueChanged<int> onLengthChanged;

  const PinGeneratorControls({
    super.key,
    required this.length,
    required this.onLengthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(text: l.labelPinLength, fontSize: 16, color: accent),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 4, label: Text('4')),
            ButtonSegment(value: 6, label: Text('6')),
          ],
          selected: {length},
          onSelectionChanged: (s) => onLengthChanged(s.first),
        ),
      ],
    );
  }
}
