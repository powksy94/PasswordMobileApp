import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecretAdminTapZone extends StatefulWidget {
  final VoidCallback onTap;

  const SecretAdminTapZone({super.key, required this.onTap});

  @override
  State<SecretAdminTapZone> createState() => _SecretAdminTapZoneState();
}

class _SecretAdminTapZoneState extends State<SecretAdminTapZone>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _rotation;
  bool _showLock = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    _tapCount++;

    // Reset automatique après 1 seconde
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _tapCount = 0;
    });

    if (_tapCount == 5) {
      setState(() => _showLock = true);
      _controller.forward(from: 0);
      HapticFeedback.lightImpact();

      // Appel callback après animation
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() => _showLock = false);
          widget.onTap();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.translucent, // zone invisible mais tappable
            child: Container(color: Colors.transparent),
          ),
          if (_showLock)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Transform.rotate(
                      angle: _rotation.value,
                      child: const Icon(
                        Icons.lock_open_rounded,
                        size: 32,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
