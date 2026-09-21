import 'package:flutter/material.dart';
import '../../utils/pin_score.dart';
import '../../utils/strength_level.dart';
import '../../../l10n/app_localizations.dart';

class PinScoreBar extends StatelessWidget {
  final String pin;

  const PinScoreBar({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    final score = PinScore.compute(pin);
    final color = PinScore.color(score);
    final label = PinScore.level(score).label(AppLocalizations.of(context)!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height:   8,
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment:   Alignment.centerLeft,
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                color:        color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color:        color.withValues(alpha: 0.6),
                    blurRadius:   6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color:      color,
            fontSize:   12,
            fontWeight: FontWeight.bold,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
