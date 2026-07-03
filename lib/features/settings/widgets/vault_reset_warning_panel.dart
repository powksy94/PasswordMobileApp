import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common/glass_panel.dart';

class VaultResetWarningPanel extends StatelessWidget {
  final bool     understood;
  final ValueChanged<bool> onChanged;

  const VaultResetWarningPanel({
    super.key,
    required this.understood,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
            const SizedBox(width: 8),
            Text(
              l.warningResetVaultTitle,
              style: const TextStyle(
                color:      Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize:   15,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
            l.warningResetVaultBody,
            style: TextStyle(
              color:  isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          CheckboxListTile(
            value:           understood,
            onChanged:       (v) => onChanged(v ?? false),
            title:           Text(l.checkboxUnderstandVaultReset,
                style: const TextStyle(fontSize: 13)),
            activeColor:     Colors.redAccent,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding:  EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
