import 'package:flutter/material.dart';
import './gradient_background.dart';
import './neon_text.dart';

/// Squelette de page commun (AppBar transparent + titre néon + dégradé de
/// fond), dupliqué jusqu'ici dans la majorité des pages de l'app — chaque
/// page ne porte plus que son propre contenu, pas ce "chrome" visuel partagé.
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
