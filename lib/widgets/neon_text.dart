import 'package:flutter/material.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final bool glow;
  final bool bold; // ← Ajouté

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 24,
    required this.color,
    this.glow = false,
    this.bold = false, // ← par défaut false
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal, // ← Utilise bold
        color: color,
        shadows: glow
            ? [
                Shadow(
                  color: color.withOpacity(0.7),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
    );
  }
}
