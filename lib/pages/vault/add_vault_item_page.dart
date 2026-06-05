import 'package:flutter/material.dart';
import '../../services/vault_service.dart';
import '../../widgets/common/glass_panel.dart';
import '../../widgets/common/neon_text.dart';
import '../../widgets/common/password_strength_bar.dart';
import '../../widgets/vault/icon_selector.dart';
import '../../l10n/app_localizations.dart';

class AddVaultItemPage extends StatefulWidget {
  const AddVaultItemPage({super.key});

  @override
  State<AddVaultItemPage> createState() => _AddVaultItemPageState();
}

class _AddVaultItemPageState extends State<AddVaultItemPage> {
  final _labelCtrl    = TextEditingController();
  final _loginCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _urlCtrl      = TextEditingController();
  String _selectedIcon = 'lock';
  bool _showPassword   = false;
  bool _saving         = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    _notesCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (_labelCtrl.text.trim().isEmpty) {
      _snack(l.errorLabelRequired);
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      _snack(l.errorPasswordRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      await VaultService.addToServer(
        label:    _labelCtrl.text.trim(),
        login:    _loginCtrl.text.trim(),
        password: _passwordCtrl.text,
        notes:    _notesCtrl.text.trim(),
        icon:     _selectedIcon,
        url:      _urlCtrl.text.trim(),
      );
      if (!mounted) return;
      _snack(l.successAdded);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(text: l.titleAdd, fontSize: 20, color: accent, glow: true),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassPanel(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _labelCtrl,
                    decoration: InputDecoration(
                      labelText:  l.itemLabel,
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _loginCtrl,
                    decoration: InputDecoration(
                      labelText:  l.itemLogin,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller:  _passwordCtrl,
                    obscureText: !_showPassword,
                    onChanged:   (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText:  l.itemPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PasswordStrengthBar(password: _passwordCtrl.text),
                  const SizedBox(height: 12),
                  TextField(
                    controller:   _urlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText:  l.itemWebsite,
                      hintText:   l.itemWebsiteHint,
                      prefixIcon: const Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    maxLines:   3,
                    decoration: InputDecoration(
                      labelText:          l.itemNotes,
                      prefixIcon:         const Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.itemIcon,
                    style: TextStyle(
                      color:    isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconSelector(
                    selected:  _selectedIcon,
                    onChanged: (v) => setState(() => _selectedIcon = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_saving ? l.btnAdding : l.btnAddToVault),
            ),
          ],
        ),
      ),
    );
  }
}
