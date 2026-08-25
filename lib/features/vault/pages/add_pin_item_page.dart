import 'package:flutter/material.dart';
import '../services/vault_service.dart';
import '../../../shared/widgets/common/app_page_scaffold.dart';
import '../widgets/pin_item_form.dart';
import '../../../l10n/app_localizations.dart';

class AddPinItemPage extends StatefulWidget {
  const AddPinItemPage({super.key});

  @override
  State<AddPinItemPage> createState() => _AddPinItemPageState();
}

class _AddPinItemPageState extends State<AddPinItemPage> {
  final _labelCtrl = TextEditingController();
  final _pinCtrl   = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _showPin = false;
  bool _saving  = false;

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
      await VaultService.addToServer(
        type:  'pin',
        label: _labelCtrl.text.trim(),
        password: '',
        pin:      _pinCtrl.text,
        notes:    _notesCtrl.text.trim(),
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
                : const Icon(Icons.add),
            label: Text(_saving ? l.btnAdding : l.btnAddToVault),
          ),
        ],
      ),
    );
  }
}
