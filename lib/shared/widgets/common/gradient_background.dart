import 'package:flutter/material.dart';

/// Dégradé de fond dépendant du thème, dupliqué jusqu'ici dans chaque page
/// (coffre, réglages, formulaires) — extrait tel quel, sans changement visuel.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.black, Colors.grey[900]!]
              : [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
