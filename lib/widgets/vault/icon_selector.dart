import 'package:flutter/material.dart';

const vaultIconOptions = <(String, IconData, String)>[
  ('lock',        Icons.lock,        'Cadenas'),
  ('email',       Icons.email,       'Email'),
  ('wifi',        Icons.wifi,        'Wi-Fi'),
  ('credit_card', Icons.credit_card, 'Carte'),
  ('person',      Icons.person,      'Compte'),
  ('vpn_key',     Icons.vpn_key,     'Clé VPN'),
  ('phone',       Icons.phone,       'Téléphone'),
  ('computer',    Icons.computer,    'Ordinateur'),
  ('cloud',       Icons.cloud,       'Cloud'),
];

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

    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: vaultIconOptions.map((opt) {
        final isSelected = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Tooltip(
            message: opt.$3,
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
