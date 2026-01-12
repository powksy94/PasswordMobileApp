import 'package:flutter/material.dart';
import 'glass_panel.dart';

class SplashAuthGate extends StatefulWidget {
  const SplashAuthGate({super.key});
  @override
  State<SplashAuthGate> createState() => _SplashAuthGateState();
}

class _SplashAuthGateState extends State<SplashAuthGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: GlassPanel(
          width: 260,
          height: 160,
          blur: 8,
          borderRadius: 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 50, color: isDark ? Colors.cyanAccent : Colors.blueAccent),
              const SizedBox(height: 12),
              Text(
                "Password App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Chargement...",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
