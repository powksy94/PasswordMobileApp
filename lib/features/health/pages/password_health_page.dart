import 'package:flutter/material.dart';
import '../../vault/services/vault_service.dart';
import '../../vault/models/vault_item.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../shared/widgets/common/gradient_background.dart';
import '../widgets/password_health_section.dart';
import '../widgets/pin_health_section.dart';
import '../../vault/pages/vault_item_navigation.dart';
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

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await VaultService.loadFromServer();
      if (mounted) setState(() { _items = result.items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // Le détail de l'analyse (score, faibles, réutilisés) vit dans
  // PasswordHealthSection/PinHealthSection, chacune autonome à partir de la
  // sous-liste d'items de son type — cette page ne fait que charger et router.
  List<VaultItem> get _passwordItems =>
      _items.where((i) => i.type != 'pin').toList();

  List<VaultItem> get _pinItems =>
      _items.where((i) => i.type == 'pin').toList();

  Future<void> _openEdit(VaultItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VaultItemNavigation.editPageFor(item)),
    );
    await _load();
  }

  // ── Build — pas de Scaffold ni d'AppBar (géré par HomePage) ──────────────

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('${l.errorPrefix}: $_error',
            style: const TextStyle(color: Colors.redAccent)),
      );
    }

    final passwordItems = _passwordItems;
    final pinItems      = _pinItems;

    return GradientBackground(
      child: (passwordItems.isEmpty && pinItems.isEmpty)
          ? Center(
              child: NeonText(
                  text: l.vaultEmpty, fontSize: 20, color: accent, glow: true))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (passwordItems.isNotEmpty)
                  PasswordHealthSection(items: passwordItems, onEdit: _openEdit),

                if (pinItems.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  PinHealthSection(items: pinItems, onEdit: _openEdit),
                ],

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
