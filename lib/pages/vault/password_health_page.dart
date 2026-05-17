import 'package:flutter/material.dart';
import '../../services/vault_service.dart';
import '../../models/vault_item.dart';
import '../../utils/password_score.dart';
import '../../widgets/common/neon_text.dart';
import '../../widgets/common/glass_panel.dart';
import '../../widgets/health/health_score_card.dart';
import '../../widgets/health/health_section_header.dart';
import '../../widgets/health/health_item_tile.dart';
import 'edit_vault_item_page.dart';

class PasswordHealthPage extends StatefulWidget {
  const PasswordHealthPage({super.key});

  @override
  State<PasswordHealthPage> createState() => PasswordHealthPageState();
}

// State public → accessible via GlobalKey depuis HomePage
class PasswordHealthPageState extends State<PasswordHealthPage> {
  List<VaultItem> _items = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Action publique (appelée par HomePage via GlobalKey) ──────────────────

  Future<void> refresh() => _load();

  // ── Analyses ───────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await VaultService.loadFromServer();
      if (mounted) setState(() { _items = result.items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<VaultItem> get _weak =>
      _items.where((i) => PasswordScore.compute(i.password) < 60).toList();

  List<List<VaultItem>> get _duplicateGroups {
    final map = <String, List<VaultItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.password, () => []).add(item);
    }
    return map.values.where((g) => g.length > 1).toList();
  }

  int get _globalScore {
    if (_items.isEmpty) return 100;
    return (_items
            .map((i) => PasswordScore.compute(i.password))
            .fold(0, (a, b) => a + b) /
        _items.length)
        .round();
  }

  Future<void> _openEdit(VaultItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditVaultItemPage(item: item)),
    );
    await _load();
  }

  // ── Build — pas de Scaffold ni d'AppBar (géré par HomePage) ──────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('Erreur : $_error',
            style: const TextStyle(color: Colors.redAccent)),
      );
    }

    final weak       = _weak;
    final duplicates = _duplicateGroups;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.black, Colors.grey[900]!]
              : [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
      ),
      child: _items.isEmpty
          ? Center(
              child: NeonText(
                  text: 'Coffre vide', fontSize: 20, color: accent, glow: true))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                HealthScoreCard(
                  score:       _globalScore,
                  total:       _items.length,
                  strongCount: _items
                      .where((i) => PasswordScore.compute(i.password) >= 80)
                      .length,
                  weakCount:   weak.length,
                  dupCount:    duplicates.fold(0, (s, g) => s + g.length),
                ),

                if (weak.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HealthSectionHeader(
                    icon:     Icons.warning_amber_rounded,
                    title:    'Mots de passe faibles (${weak.length})',
                    subtitle: 'Score < 60 — à remplacer en priorité',
                    color:    Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  GlassPanel(
                    width:   double.infinity,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: weak
                          .map((i) =>
                              HealthItemTile(item: i, onEdit: () => _openEdit(i)))
                          .toList(),
                    ),
                  ),
                ],

                if (duplicates.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HealthSectionHeader(
                    icon:     Icons.copy_all,
                    title:    'Mots de passe réutilisés (${duplicates.length} groupe(s))',
                    subtitle: 'Le même mot de passe est utilisé sur plusieurs services',
                    color:    Colors.orangeAccent,
                  ),
                  const SizedBox(height: 8),
                  ...duplicates.map((group) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          width:   double.infinity,
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                                child: Text(
                                  '${group.length} services — même mot de passe',
                                  style: const TextStyle(
                                    color:      Colors.orangeAccent,
                                    fontSize:   12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...group.map((i) =>
                                  HealthItemTile(item: i, onEdit: () => _openEdit(i))),
                            ],
                          ),
                        ),
                      )),
                ],

                if (weak.isEmpty && duplicates.isEmpty) ...[
                  const SizedBox(height: 20),
                  GlassPanel(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Icon(Icons.verified_rounded,
                            color: Colors.cyanAccent, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Excellent ! Aucun problème détecté.',
                          style: TextStyle(
                            color:      isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
