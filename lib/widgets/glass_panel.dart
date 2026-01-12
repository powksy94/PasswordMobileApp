import 'package:flutter/material.dart';
import 'dart:ui';

class GlassPanel extends StatelessWidget {
  final double width;
  final double? height;
  final double blur;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget child;

  // Glow/border options
  final bool glow;
  final double glowIntensity;

  const GlassPanel({
    super.key,
    required this.width,
    this.height,
    this.blur = 5,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    required this.child,
    this.glow = true,
    this.glowIntensity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color borderColor = isDark
        ? Colors.cyanAccent.withOpacity(0.7)
        : Colors.blueAccent.withOpacity(0.7);

    final Color panelColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(glowIntensity),
                      blurRadius: 20,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
