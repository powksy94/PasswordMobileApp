import 'package:flutter/material.dart';

class NeonText extends StatelessWidget {
  final String        text;
  final double        fontSize;
  final Color         color;
  final bool          glow;
  final bool          bold;
  final int?          maxLines;
  final TextOverflow? overflow;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 24,
    required this.color,
    this.glow     = false,
    this.bold     = false,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign:  TextAlign.center,
      maxLines:   maxLines,
      overflow:   overflow,
      style: TextStyle(
        fontSize:   fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color:      color,
        shadows: glow
            ? [
                Shadow(
                  color:      color.withValues(alpha: 0.7),
                  blurRadius: 10,
                  offset:     const Offset(0, 0),
                ),
                Shadow(
                  color:      color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset:     const Offset(0, 0),
                ),
              ]
            : null,
      ),
    );
  }
}
