import 'package:flutter/material.dart';
import '../../vault/services/vault_service.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/utils/password_score.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../shared/widgets/common/gradient_background.dart';
import '../widgets/health_score_card.dart';
import '../widgets/weak_passwords_section.dart';
import '../widgets/reused_passwords_section.dart';
import '../widgets/health_all_good_panel.dart';
import '../../vault/pages/edit_vault_item_page.dart';
import '../../../l10n/app_localizations.dart';

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
        child: Text('${AppLocalizations.of(context)!.errorPrefix}: $_error',
            style: const TextStyle(color: Colors.redAccent)),
      );
    }

    final weak       = _weak;
    final duplicates = _duplicateGroups;

    return GradientBackground(
      child: _items.isEmpty
          ? Center(
              child: NeonText(
                  text: AppLocalizations.of(context)!.vaultEmpty, fontSize: 20, color: accent, glow: true))
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
                  WeakPasswordsSection(items: weak, onEdit: _openEdit),
                ],

                if (duplicates.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ReusedPasswordsSection(groups: duplicates, onEdit: _openEdit),
                ],

                if (weak.isEmpty && duplicates.isEmpty) ...[
                  const SizedBox(height: 20),
                  const HealthAllGoodPanel(),
                ],

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
