import 'package:flutter/material.dart';
import '../common/neon_text.dart';

/// Slider de longueur + cases à cocher des jeux de caractères.
/// Purement présentatif — chaque changement remonte via callback.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text:     'Longueur : $length',
          fontSize: 16,
          color:    accent,
        ),
        Slider(
          value:     length.toDouble(),
          min:       4,
          max:       64,
          divisions: 60,
          label:     '$length',
          onChanged: (v) => onLengthChanged(v.toInt()),
        ),
        CheckboxListTile(
          value:     useLower,
          onChanged: (v) => onLowerChanged(v!),
          title:     const Text('Minuscules'),
        ),
        CheckboxListTile(
          value:     useUpper,
          onChanged: (v) => onUpperChanged(v!),
          title:     const Text('Majuscules'),
        ),
        CheckboxListTile(
          value:     useDigits,
          onChanged: (v) => onDigitsChanged(v!),
          title:     const Text('Chiffres'),
        ),
        CheckboxListTile(
          value:     useSpecials,
          onChanged: (v) => onSpecialsChanged(v!),
          title:     const Text('Spéciaux'),
        ),
      ],
    );
  }
}
