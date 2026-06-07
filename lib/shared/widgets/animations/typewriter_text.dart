import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String        text;
  final TextStyle?    style;
  final Duration      charDelay;
  final Duration      startDelay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay  = const Duration(milliseconds: 60),
    this.startDelay = Duration.zero,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayed = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.startDelay, _start);
  }

  void _start() {
    int index = 0;
    _timer = Timer.periodic(widget.charDelay, (t) {
      if (!mounted) { t.cancel(); return; }
      if (index >= widget.text.length) {
        t.cancel();
        widget.onComplete?.call();
        return;
      }
      setState(() => _displayed = widget.text.substring(0, ++index));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayed,
      textAlign: TextAlign.center,
      style: widget.style ?? TextStyle(
        fontSize:      22,
        fontWeight:    FontWeight.bold,
        letterSpacing: 2,
        color:         Colors.cyanAccent,
        shadows: const [
          Shadow(color: Colors.cyan,       blurRadius: 8),
          Shadow(color: Colors.blueAccent, blurRadius: 20),
        ],
      ),
    );
  }
}
