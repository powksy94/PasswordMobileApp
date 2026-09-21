import 'package:flutter/material.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../l10n/app_localizations.dart';

/// Length slider + checkboxes for the character sets.
/// Purely presentational: every change bubbles up via callback.
class GeneratorControls extends StatelessWidget {
  final int  length;
  final bool useLower;
  final bool useUpper;
  final bool useDigits;
  final bool useSpecials;

  final void Function(int)  onLengthChanged;
  final void Function(bool) onLowerChanged;
  final void Function(bool) onUpperChanged;
  final void Function(bool) onDigitsChanged;
  final void Function(bool) onSpecialsChanged;

  const GeneratorControls({
    super.key,
    required this.length,
    required this.useLower,
    required this.useUpper,
    required this.useDigits,
    required this.useSpecials,
    required this.onLengthChanged,
    required this.onLowerChanged,
    required this.onUpperChanged,
    required this.onDigitsChanged,
    required this.onSpecialsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final l      = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text:     l.generatorLength(length),
          fontSize: 16,
          color:    accent,
        ),
        Slider(
          value:     length.toDouble(),
          min:       4,
          max:       40,
          divisions: 36,
          label:     '$length',
          onChanged: (v) => onLengthChanged(v.toInt()),
        ),
        CheckboxListTile(
          value:     useLower,
          onChanged: (v) => onLowerChanged(v!),
          title:     Text(l.generatorLowercase),
        ),
        CheckboxListTile(
          value:     useUpper,
          onChanged: (v) => onUpperChanged(v!),
          title:     Text(l.generatorUppercase),
        ),
        CheckboxListTile(
          value:     useDigits,
          onChanged: (v) => onDigitsChanged(v!),
          title:     Text(l.generatorDigits),
        ),
        CheckboxListTile(
          value:     useSpecials,
          onChanged: (v) => onSpecialsChanged(v!),
          title:     Text(l.generatorSpecials),
        ),
      ],
    );
  }
}
