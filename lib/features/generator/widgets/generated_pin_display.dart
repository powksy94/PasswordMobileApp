import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

class GeneratedPinDisplay extends StatelessWidget {
  final String       pin;
  final bool         showPin;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;

  const GeneratedPinDisplay({
    super.key,
    required this.pin,
    required this.showPin,
    required this.onToggleVisibility,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return GlassPanel(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              pin.isEmpty
                  ? l.pinEmpty
                  : (showPin ? pin : '●●●●●●●●'),
              style: TextStyle(fontSize: 20, color: accent),
            ),
          ),
          if (pin.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                showPin ? Icons.visibility_off : Icons.visibility,
                color: Colors.orangeAccent,
              ),
              onPressed: onToggleVisibility,
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.greenAccent),
              onPressed: onCopy,
            ),
          ],
        ],
      ),
    );
  }
}
