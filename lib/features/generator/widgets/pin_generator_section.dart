import 'package:flutter/material.dart';
import '../services/pin_generator.dart';
import '../services/pin_generator_controller.dart';
import './generated_pin_result_panel.dart';
import './pin_generator_controls.dart';
import '../../../l10n/app_localizations.dart';

/// Mirroring de [PasswordGeneratorSection] pour les PINs — widget fin,
/// orchestration dans [PinGeneratorController], rendu du résultat dans
/// [GeneratedPinResultPanel].
class PinGeneratorSection extends StatefulWidget {
  final VoidCallback? onVaultUpdated;

  const PinGeneratorSection({super.key, this.onVaultUpdated});

  @override
  State<PinGeneratorSection> createState() => _PinGeneratorSectionState();
}

class _PinGeneratorSectionState extends State<PinGeneratorSection> {
  final _controller = PinGeneratorController();

  int length = 4;

  String pin     = '';
  bool   showPin = false;

  final _labelCtrl  = TextEditingController();
  final _notesCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      pin     = PinGenerator.generate(length: length);
      showPin = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _addToVault() async {
    final l = AppLocalizations.of(context)!;
    try {
      await _controller.addToVault(
        label: _labelCtrl.text,
        pin:   pin,
        notes: _notesCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.snackPinAdded)));
      widget.onVaultUpdated?.call();
      setState(() { pin = ''; showPin = false; });
      _labelCtrl.clear();
      _notesCtrl.clear();
    } on MissingLabelException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorLabelMissing)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _copyPin() async {
    if (pin.isEmpty) return;
    await _controller.copy(pin);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.snackCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollCtrl,
      children: [
        PinGeneratorControls(
          length:          length,
          onLengthChanged: (v) => setState(() => length = v),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _generate,
          icon:  const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context)!.btnGenerate),
        ),
        if (pin.isNotEmpty) ...[
          const SizedBox(height: 12),
          GeneratedPinResultPanel(
            pin:                pin,
            showPin:            showPin,
            onToggleVisibility: () => setState(() => showPin = !showPin),
            onCopy:             _copyPin,
            labelController:    _labelCtrl,
            notesController:    _notesCtrl,
            onAddToVault:       _addToVault,
          ),
        ],
      ],
    );
  }
}
