import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

class MasterPasswordWarningPanel extends StatelessWidget {
  final bool understood;
  final ValueChanged<bool> onUnderstoodChanged;
  final bool enabled;

  const MasterPasswordWarningPanel({
    super.key,
    required this.understood,
    required this.onUnderstoodChanged,
    required this.enabled,
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
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.warningChangeMasterPasswordTitle,
                  style: const TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.bold,
                    color:      Colors.orangeAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.warningChangeMasterPasswordBody,
            style: TextStyle(
              color:  isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: understood,
            onChanged: enabled ? (v) => onUnderstoodChanged(v ?? false) : null,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.orangeAccent,
            title: Text(
              l.checkboxUnderstandRisks,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
