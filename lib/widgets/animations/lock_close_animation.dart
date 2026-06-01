import 'package:flutter/material.dart';

class LockCloseAnimation extends StatefulWidget {
  final double size;
  final Duration delay;
  final VoidCallback? onClosed;

  const LockCloseAnimation({
    super.key,
    this.size     = 96,
    this.delay    = const Duration(milliseconds: 400),
    this.onClosed,
  });

  @override
  State<LockCloseAnimation> createState() => _LockCloseAnimationState();
}

class _LockCloseAnimationState extends State<LockCloseAnimation>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double>   _bounce;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );
    _bounce = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);

    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _ctrl.forward().then((_) {
        if (!mounted) return;
        setState(() => _closed = true);
        widget.onClosed?.call();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) {
        final scale = _closed ? (0.85 + 0.15 * _bounce.value) : 1.0;
        return Transform.scale(
          scale: scale,
          child: AnimatedSwitcher(
            duration:       const Duration(milliseconds: 150),
            switchInCurve:  Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: Icon(
              _closed ? Icons.lock_rounded : Icons.lock_open_rounded,
              key:   ValueKey(_closed),
              size:  widget.size,
              color: Colors.white,
              shadows: const [
                Shadow(color: Colors.white54, blurRadius: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
