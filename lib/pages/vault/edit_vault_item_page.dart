import 'package:flutter/material.dart';
import '../../services/vault_service.dart';
import '../../models/vault_item.dart';
import '../../widgets/common/glass_panel.dart';
import '../../widgets/common/neon_text.dart';
import '../../widgets/common/password_strength_bar.dart';
import '../../widgets/vault/icon_selector.dart';

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
    _selectedIcon = widget.item.icon;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_labelCtrl.text.trim().isEmpty) {
      _snack('Le label est requis');
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      _snack('Le mot de passe est requis');
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
      );
      if (!mounted) return;
      _snack('Modifié avec succès');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(text: 'Modifier', fontSize: 20, color: accent, glow: true),
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
                    decoration: const InputDecoration(
                      labelText:  'Label *',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _loginCtrl,
                    decoration: const InputDecoration(
                      labelText:  'Login / Email',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller:  _passwordCtrl,
                    obscureText: !_showPassword,
                    onChanged:   (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText:  'Mot de passe *',
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
                    controller: _notesCtrl,
                    maxLines:   3,
                    decoration: const InputDecoration(
                      labelText:         'Notes',
                      prefixIcon:        Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Icône',
                    style: TextStyle(
                      color:    isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ← IconSelector remplace l'inline Wrap
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
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Sauvegarde…' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
