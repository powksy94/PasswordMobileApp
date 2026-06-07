import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/password_generator.dart';
import '../../vault/services/vault_service.dart';
import '../../../shared/services/clipboard_service.dart';
import '../../../shared/widgets/common/password_strength_bar.dart';
import '../widgets/generated_password_display.dart';
import '../widgets/generator_controls.dart';
import '../widgets/vault_save_form.dart';
import '../../../l10n/app_localizations.dart';

class PasswordGeneratorPage extends StatefulWidget {
  final VoidCallback? onVaultUpdated;

  const PasswordGeneratorPage({super.key, this.onVaultUpdated});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  // Paramètres du générateur
  int    length      = 16;
  bool   useLower    = true;
  bool   useUpper    = true;
  bool   useDigits   = true;
  bool   useSpecials = true;
  bool   requireAll  = true;
  String exclude     = '';

  // État du mot de passe affiché
  String password     = '';
  bool   showPassword = false;

  // Champs de sauvegarde
  final _labelCtrl    = TextEditingController();
  final _loginCtrl    = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _urlCtrl      = TextEditingController();
  final _scrollCtrl   = ScrollController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _loginCtrl.dispose();
    _notesCtrl.dispose();
    _urlCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Logique ───────────────────────────────────────────────────────────────

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
    if (_labelCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorLabelMissing)),
      );
      return;
    }
    try {
      await VaultService.addToServer(
        label:    _labelCtrl.text,
        login:    _loginCtrl.text,
        password: password,
        notes:    _notesCtrl.text,
        icon:     'lock',
        url:      _urlCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.snackPasswordAdded)),
      );
      widget.onVaultUpdated?.call();
      setState(() {
        password     = '';
        showPassword = false;
      });
      _labelCtrl.clear();
      _loginCtrl.clear();
      _notesCtrl.clear();
      _urlCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  void _copyPassword() async {
    if (password.isEmpty) return;
    await ClipboardService.copyAndScheduleClear(password);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.snackCopied)),
    );
  }

  // ── Build — pas de Scaffold (géré par HomePage) ──────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
            controller: _scrollCtrl,
            children: [
              GeneratorControls(
                length:           length,
                useLower:         useLower,
                useUpper:         useUpper,
                useDigits:        useDigits,
                useSpecials:      useSpecials,
                onLengthChanged:  (v) => setState(() => length      = v),
                onLowerChanged:   (v) => setState(() => useLower    = v),
                onUpperChanged:   (v) => setState(() => useUpper    = v),
                onDigitsChanged:  (v) => setState(() => useDigits   = v),
                onSpecialsChanged:(v) => setState(() => useSpecials  = v),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _generate,
                icon:  const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.btnGenerate),
              ),
              if (password.isNotEmpty) ...[
                const SizedBox(height: 12),
                GeneratedPasswordDisplay(
                  password:           password,
                  showPassword:       showPassword,
                  onToggleVisibility: () => setState(() => showPassword = !showPassword),
                  onCopy:             _copyPassword,
                ),
                const SizedBox(height: 8),
                PasswordStrengthBar(password: password),
                const SizedBox(height: 12),
                VaultSaveForm(
                  labelController: _labelCtrl,
                  loginController: _loginCtrl,
                  notesController: _notesCtrl,
                  urlController:   _urlCtrl,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addToVault,
                  icon:  const FaIcon(FontAwesomeIcons.vault),
                  label: Text(AppLocalizations.of(context)!.btnAddToVault),
                ),
              ],
            ],
      ),
    );
  }
}
