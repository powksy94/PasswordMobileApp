import 'package:flutter/material.dart';
import '../../utils/password_score.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final score = PasswordScore.compute(password);
    final color = PasswordScore.color(score);
    final label = PasswordScore.label(score);

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
