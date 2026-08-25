import 'package:flutter/material.dart';
import '../services/vault_service.dart';
import '../models/vault_item.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../widgets/pin_item_form.dart';
import '../../../l10n/app_localizations.dart';

class EditPinItemPage extends StatefulWidget {
  final VaultItem item;
  const EditPinItemPage({super.key, required this.item});

  @override
  State<EditPinItemPage> createState() => _EditPinItemPageState();
}

class _EditPinItemPageState extends State<EditPinItemPage> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _pinCtrl;
  late final TextEditingController _notesCtrl;
  bool _showPin = false;
  bool _saving  = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.item.label);
    _pinCtrl   = TextEditingController(text: widget.item.pin);
    _notesCtrl = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _pinCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (_labelCtrl.text.trim().isEmpty) {
      _snack(l.errorLabelRequired);
      return;
    }
    if (_pinCtrl.text.isEmpty) {
      _snack(l.errorPinRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      await VaultService.updateOnServer(
        id:    widget.item.id,
        type:  'pin',
        label: _labelCtrl.text.trim(),
        password: '',
        pin:      _pinCtrl.text,
        notes:    _notesCtrl.text.trim(),
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
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(text: l.titleEdit, fontSize: 20, color: accent, glow: true),
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
            PinItemForm(
              labelCtrl: _labelCtrl,
              pinCtrl:   _pinCtrl,
              notesCtrl: _notesCtrl,
              showPin:   _showPin,
              onTogglePinVisibility: () => setState(() => _showPin = !_showPin),
              onPinChanged: () => setState(() {}),
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
      ),
    );
  }
}
