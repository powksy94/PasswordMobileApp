import 'package:flutter/material.dart';

/// Theme-dependent background gradient, previously duplicated in every page
/// (vault, settings, forms), extracted as-is with no visual change.
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
