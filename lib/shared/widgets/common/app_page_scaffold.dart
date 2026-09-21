import 'package:flutter/material.dart';
import './gradient_background.dart';
import './neon_text.dart';

/// Shared page skeleton (transparent AppBar + neon title + background
/// gradient), previously duplicated across most pages of the app. Each
/// page now only carries its own content, not this shared visual "chrome".
class AppPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool   safeArea;

  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.safeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(text: title, fontSize: 20, color: accent, glow: true),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: safeArea ? SafeArea(bottom: true, child: body) : body,
      ),
    );
  }
}
