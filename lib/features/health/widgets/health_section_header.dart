import 'package:flutter/material.dart';

class HealthSectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final Color    color;

  const HealthSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color:      color,
                  fontWeight: FontWeight.bold,
                  fontSize:   14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color:    color.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
