import 'package:flutter/material.dart';

class TutorialBubble extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   body;
  final bool     visible;
  final VoidCallback onDismiss;

  const TutorialBubble({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.visible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: visible
          ? Container(
              key:     const ValueKey('bubble'),
              margin:  const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(icon, color: accent, size: 20),
                    const SizedBox(width: 8),
                    Text(title,
                        style: TextStyle(
                          color:      accent,
                          fontSize:   14,
                          fontWeight: FontWeight.bold,
                        )),
                  ]),
                  const SizedBox(height: 10),
                  Text(body,
                      style: TextStyle(
                        fontSize: 13,
                        height:   1.5,
                        color:    isDark ? Colors.white70 : Colors.black87,
                      )),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onDismiss,
                      icon:  Icon(Icons.arrow_forward, size: 16, color: accent),
                      label: Text('J\'ai compris',
                          style: TextStyle(color: accent, fontSize: 13)),
                      style: TextButton.styleFrom(
                        padding:         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: accent.withValues(alpha: 0.1),
                        shape:           RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}
