import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

class DangerZonePanel extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onResetVault;

  const DangerZonePanel({
    super.key,
    required this.onDelete,
    required this.onResetVault,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.titleDangerZone,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.bold,
              color:      Colors.redAccent,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onResetVault,
              icon:  const Icon(Icons.delete_sweep, color: Colors.orangeAccent),
              label: Text(
                l.btnDangerResetVault,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
              style: OutlinedButton.styleFrom(
                side:    const BorderSide(color: Colors.orangeAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon:  const Icon(Icons.delete_forever, color: Colors.redAccent),
              label: Text(
                l.btnDeleteAccount,
                style: const TextStyle(color: Colors.redAccent),
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
