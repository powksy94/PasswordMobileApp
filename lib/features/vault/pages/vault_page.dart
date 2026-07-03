import 'package:flutter/material.dart';
import '../services/vault_service.dart';
import '../../../shared/services/clipboard_service.dart';
import '../models/vault_item.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../widgets/vault_item_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/vault_search_bar.dart';
import '../../../l10n/app_localizations.dart';
import './add_vault_item_page.dart';
import './edit_vault_item_page.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => VaultPageState();
}

class VaultPageState extends State<VaultPage> {
  List<VaultItem> _items     = [];
  bool            _fromCache = false;
  final Map<String, bool>     _showPassword    = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadVault();
    VaultService.vaultVersion.addListener(_onVaultVersionChanged);
  }

  @override
  void dispose() {
    VaultService.vaultVersion.removeListener(_onVaultVersionChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onVaultVersionChanged() => loadVault();

  List<VaultItem> get _filtered {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items
        .where((i) =>
            i.label.toLowerCase().contains(q) ||
            i.login.toLowerCase().contains(q))
        .toList();
  }

  // ── Actions publiques (appelées par HomePage via GlobalKey) ───────────────

  Future<void> loadVault() async {
    try {
      final result = await VaultService.loadFromServer();
      for (final item in result.items) {
        _showPassword.putIfAbsent(item.id, () => false);
      }
      if (mounted) {
        setState(() {
          _items     = result.items;
          _fromCache = result.fromCache;
        });
      }
    } on VaultDecryptionException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.errorVaultDecryptionFailed),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> openAddPassword() async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVaultItemPage()),
    );
    if (result == true) await loadVault();
  }

  // ── Actions internes ──────────────────────────────────────────────────────

  Future<void> _deleteItem(String id) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   Text(l.dialogDeleteTitle),
        content: Text(l.dialogDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l.btnDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await VaultService.deleteFromServer(id);
      await loadVault();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.snackItemDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _copyToClipboard(String text, String label) async {
    await ClipboardService.copyAndScheduleClear(text);
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — ${l.snackCopied}')),
    );
  }

  Future<void> _openEdit(VaultItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditVaultItemPage(item: item)),
    );
    await loadVault();
  }

  // ── Build — pas de Scaffold ni d'AppBar (géré par HomePage) ──────────────

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

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
      child: Column(
        children: [
          if (_fromCache) const OfflineBanner(),
          VaultSearchBar(
            controller: _searchController,
            query:      _searchQuery,
            onChanged:  (v) => setState(() => _searchQuery = v),
            onClear:    () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: NeonText(
                      text:     _searchQuery.isEmpty
                          ? l.vaultEmpty
                          : l.vaultNoResults,
                      fontSize: 20,
                      color:    accent,
                      glow:     true,
                    ),
                  )
                : ListView.builder(
                    padding:     const EdgeInsets.all(16),
                    itemCount:   _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      return VaultItemCard(
                        item:             item,
                        showPassword:     _showPassword[item.id] ?? false,
                        onTogglePassword: () => setState(
                          () => _showPassword[item.id] =
                              !(_showPassword[item.id] ?? false)),
                        onCopy:   _copyToClipboard,
                        onEdit:   () => _openEdit(item),
                        onDelete: () => _deleteItem(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
