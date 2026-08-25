import 'package:flutter/material.dart';
import '../services/vault_service.dart';
import '../models/vault_item.dart';
import '../../../shared/widgets/common/app_page_scaffold.dart';
import '../widgets/vault_item_form.dart';
import '../../../l10n/app_localizations.dart';

class EditVaultItemPage extends StatefulWidget {
  final VaultItem item;
  const EditVaultItemPage({super.key, required this.item});

  @override
  State<EditVaultItemPage> createState() => _EditVaultItemPageState();
}

class _EditVaultItemPageState extends State<EditVaultItemPage> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _loginCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _urlCtrl;
  late String _selectedIcon;
  bool _showPassword = false;
  bool _saving       = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl    = TextEditingController(text: widget.item.label);
    _loginCtrl    = TextEditingController(text: widget.item.login);
    _passwordCtrl = TextEditingController(text: widget.item.password);
    _notesCtrl    = TextEditingController(text: widget.item.notes);
    _urlCtrl      = TextEditingController(text: widget.item.url);
    _selectedIcon = widget.item.icon;
  }

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
      await VaultService.updateOnServer(
        id:       widget.item.id,
        label:    _labelCtrl.text.trim(),
        login:    _loginCtrl.text.trim(),
        password: _passwordCtrl.text,
        notes:    _notesCtrl.text.trim(),
        icon:     _selectedIcon,
        url:      _urlCtrl.text.trim(),
      );
      if (!mounted) return;
      _snack(l.successModified);
      Navigator.pop(context);
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
      title: l.titleEdit,
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
                : const Icon(Icons.save),
            label: Text(_saving ? l.btnSaving : l.btnSave),
          ),
        ],
      ),
    );
  }
}
