import 'package:flutter/material.dart';
import '../services/vault_service.dart';
import '../../../shared/widgets/common/app_page_scaffold.dart';
import '../widgets/vault_item_form.dart';
import '../../../l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context)!;

    return AppPageScaffold(
      title: l.titleAdd,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          VaultItemForm(
            labelCtrl:    _labelCtrl,
            loginCtrl:    _loginCtrl,
            passwordCtrl: _passwordCtrl,
            urlCtrl:      _urlCtrl,
            notesCtrl:    _notesCtrl,
            selectedIcon: _selectedIcon,
            onIconChanged: (v) => setState(() => _selectedIcon = v),
            showPassword:  _showPassword,
            onTogglePasswordVisibility: () =>
                setState(() => _showPassword = !_showPassword),
            onPasswordChanged: () => setState(() {}),
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
    );
  }
}
