import 'package:flutter/material.dart';
import '../services/password_generator.dart';
import '../services/password_generator_controller.dart';
import './generated_password_result_panel.dart';
import './generator_controls.dart';
import '../../../l10n/app_localizations.dart';

/// Contenu de l'ancienne PasswordGeneratorPage — la page n'est plus qu'un
/// switcher entre ce widget et [PinGeneratorSection]. Widget fin : toute
/// l'orchestration (validation, sauvegarde, presse-papiers) vit dans
/// [PasswordGeneratorController], et le rendu du résultat dans
/// [GeneratedPasswordResultPanel].
class PasswordGeneratorSection extends StatefulWidget {
  final VoidCallback? onVaultUpdated;

  const PasswordGeneratorSection({super.key, this.onVaultUpdated});

  @override
  State<PasswordGeneratorSection> createState() => _PasswordGeneratorSectionState();
}

class _PasswordGeneratorSectionState extends State<PasswordGeneratorSection> {
  final _controller = PasswordGeneratorController();

  int    length      = 16;
  bool   useLower    = true;
  bool   useUpper    = true;
  bool   useDigits   = true;
  bool   useSpecials = true;
  bool   requireAll  = true;
  String exclude     = '';

  String password     = '';
  bool   showPassword = false;

  final _labelCtrl  = TextEditingController();
  final _loginCtrl  = TextEditingController();
  final _notesCtrl  = TextEditingController();
  final _urlCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _loginCtrl.dispose();
    _notesCtrl.dispose();
    _urlCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      password = PasswordGenerator.generate(
        length:          length,
        useLower:        useLower,
        useUpper:        useUpper,
        useDigits:       useDigits,
        useSpecials:     useSpecials,
        requireAllTypes: requireAll,
        exclude:         exclude,
      );
      showPassword = false;
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
        label:    _labelCtrl.text,
        login:    _loginCtrl.text,
        password: password,
        notes:    _notesCtrl.text,
        url:      _urlCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.snackPasswordAdded)));
      widget.onVaultUpdated?.call();
      setState(() { password = ''; showPassword = false; });
      _labelCtrl.clear();
      _loginCtrl.clear();
      _notesCtrl.clear();
      _urlCtrl.clear();
    } on MissingLabelException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorLabelMissing)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _copyPassword() async {
    if (password.isEmpty) return;
    await _controller.copy(password);
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
        GeneratorControls(
          length:            length,
          useLower:          useLower,
          useUpper:          useUpper,
          useDigits:         useDigits,
          useSpecials:       useSpecials,
          onLengthChanged:   (v) => setState(() => length      = v),
          onLowerChanged:    (v) => setState(() => useLower    = v),
          onUpperChanged:    (v) => setState(() => useUpper    = v),
          onDigitsChanged:   (v) => setState(() => useDigits   = v),
          onSpecialsChanged: (v) => setState(() => useSpecials = v),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _generate,
          icon:  const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context)!.btnGenerate),
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 12),
          GeneratedPasswordResultPanel(
            password:           password,
            showPassword:       showPassword,
            onToggleVisibility: () => setState(() => showPassword = !showPassword),
            onCopy:             _copyPassword,
            labelController:    _labelCtrl,
            loginController:    _loginCtrl,
            notesController:    _notesCtrl,
            urlController:      _urlCtrl,
            onAddToVault:       _addToVault,
          ),
        ],
      ],
    );
  }
}
