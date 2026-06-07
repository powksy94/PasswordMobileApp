import 'package:flutter/material.dart';

/// Bandeau affiché quand le vault est chargé depuis le cache local (pas de réseau).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      color:   Colors.orangeAccent.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orangeAccent),
          SizedBox(width: 8),
          Text(
            'Mode hors-ligne — données du dernier chargement',
            style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
