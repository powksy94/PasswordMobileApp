import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Shown when no weak or reused password is detected.
class HealthAllGoodPanel extends StatelessWidget {
  const HealthAllGoodPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.cyanAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            l.labelAllGood,
            style: TextStyle(
              color:      isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
