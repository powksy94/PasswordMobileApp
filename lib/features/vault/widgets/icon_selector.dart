import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

const vaultIconOptions = <(String, IconData)>[
  ('lock',        Icons.lock),
  ('email',       Icons.email),
  ('wifi',        Icons.wifi),
  ('credit_card', Icons.credit_card),
  ('person',      Icons.person),
  ('vpn_key',     Icons.vpn_key),
  ('phone',       Icons.phone),
  ('computer',    Icons.computer),
  ('cloud',       Icons.cloud),
];

/// Libellé localisé (infobulle) d'une icône de [vaultIconOptions].
String vaultIconLabel(AppLocalizations l, String id) => switch (id) {
      'lock'        => l.iconLock,
      'email'       => l.iconEmail,
      'wifi'        => l.iconWifi,
      'credit_card' => l.iconCard,
      'person'      => l.iconAccount,
      'vpn_key'     => l.iconVpnKey,
      'phone'       => l.iconPhone,
      'computer'    => l.iconComputer,
      'cloud'       => l.iconCloud,
      _             => id,
    };

class IconSelector extends StatelessWidget {
  final String            selected;
  final ValueChanged<String> onChanged;

  const IconSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final l      = AppLocalizations.of(context)!;

    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: vaultIconOptions.map((opt) {
        final isSelected = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Tooltip(
            message: vaultIconLabel(l, opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:  const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.18)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? accent
                      : (isDark ? Colors.white24 : Colors.black26),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                opt.$2,
                color: isSelected
                    ? accent
                    : (isDark ? Colors.white54 : Colors.black45),
                size: 24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
