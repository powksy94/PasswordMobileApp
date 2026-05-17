import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import '../../services/password_generator.dart';
import '../../services/vault_service.dart';
import '../../widgets/common/password_strength_bar.dart';
import '../../widgets/generator/generated_password_display.dart';
import '../../widgets/generator/generator_controls.dart';
import '../../widgets/generator/vault_save_form.dart';

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
  final _labelCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _loginCtrl.dispose();
    _notesCtrl.dispose();
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
  }

  Future<void> _addToVault() async {
    if (_labelCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un label pour le mot de passe.')),
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
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe ajouté au coffre !')),
      );
      widget.onVaultUpdated?.call();
      setState(() {
        password     = '';
        showPassword = false;
      });
      _labelCtrl.clear();
      _loginCtrl.clear();
      _notesCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout : $e")),
      );
    }
  }

  void _copyPassword() {
    if (password.isEmpty) return;
    final copied = password;
    Clipboard.setData(ClipboardData(text: copied));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe copié — effacé dans 30 s')),
    );
    Future.delayed(const Duration(seconds: 30), () async {
      final data = await Clipboard.getData('text/plain');
      if (data?.text == copied) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  // ── Build — pas de Scaffold (géré par HomePage) ──────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
            children: [
              GeneratedPasswordDisplay(
                password:           password,
                showPassword:       showPassword,
                onToggleVisibility: () => setState(() => showPassword = !showPassword),
                onCopy:             _copyPassword,
              ),
              const SizedBox(height: 8),
              PasswordStrengthBar(password: password),
              const SizedBox(height: 12),
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
              VaultSaveForm(
                labelController: _labelCtrl,
                loginController: _loginCtrl,
                notesController: _notesCtrl,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _generate,
                icon:  const Icon(Icons.refresh),
                label: const Text('Générer'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: password.isEmpty ? null : _addToVault,
                icon:  const FaIcon(FontAwesomeIcons.vault),
                label: const Text('Ajouter au coffre'),
              ),
            ],
      ),
    );
  }
}
