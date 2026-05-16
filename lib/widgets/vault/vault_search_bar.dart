import 'package:flutter/material.dart';

/// Barre de recherche du coffre-fort.
/// Filtre par label ou login. Affiche un bouton "effacer" quand la saisie est non vide.
class VaultSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String                query;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onClear;

  const VaultSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged:  onChanged,
        decoration: InputDecoration(
          hintText:   'Rechercher par label ou login…',
          prefixIcon: Icon(Icons.search, color: accent),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon:      const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          filled:    true,
          fillColor: isDark ? Colors.white10 : Colors.black12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide.none,
          ),
        ),
      ),
    );
  }
}
