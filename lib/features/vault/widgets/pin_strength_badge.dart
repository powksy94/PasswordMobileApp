import 'package:flutter/material.dart';
import '../../../shared/utils/pin_score.dart';
import '../../../shared/utils/strength_level.dart';
import '../../../l10n/app_localizations.dart';

/// Small colored badge showing the strength of a PIN (computed locally
/// from the plain value, available client-side after decryption,
/// no need to depend on the `pin_strength` returned by the server for
/// display).
class PinStrengthBadge extends StatelessWidget {
  final String pin;

  const PinStrengthBadge({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    final score = PinScore.compute(pin);
    final color = PinScore.color(score);
    final label = PinScore.level(score).label(AppLocalizations.of(context)!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
