import 'package:flutter/material.dart';
import '../common/glass_panel.dart';

class DangerZonePanel extends StatelessWidget {
  final VoidCallback onDelete;

  const DangerZonePanel({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zone dangereuse',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.bold,
              color:      Colors.redAccent,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon:  const Icon(Icons.delete_forever, color: Colors.redAccent),
              label: const Text(
                'Supprimer mon compte',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side:    const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
