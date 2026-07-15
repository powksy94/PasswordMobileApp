import 'package:flutter/material.dart';
import '../../vault/services/vault_service.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../shared/utils/password_policy.dart';
import '../widgets/master_password_warning_panel.dart';
import '../widgets/change_master_password_panel.dart';
import '../../../l10n/app_localizations.dart';

class ChangeMasterPasswordPage extends StatefulWidget {
  const ChangeMasterPasswordPage({super.key});

  @override
  State<ChangeMasterPasswordPage> createState() => _ChangeMasterPasswordPageState();
}

class _ChangeMasterPasswordPageState extends State<ChangeMasterPasswordPage> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _understood = false;
  bool _changing   = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      _snack(l.validatorMasterPasswordMismatch);
      return;
    }
    if (_newPwCtrl.text.length < PasswordPolicy.minLength) {
      _snack(l.validatorMinChars);
      return;
    }
    if (!PasswordPolicy.meetsComplexity(_newPwCtrl.text)) {
      _snack(l.validatorPasswordComplexity);
      return;
    }

    setState(() => _changing = true);
    try {
      await VaultService.changeMasterPassword(
        oldMasterPassword: _currentPwCtrl.text,
        newMasterPassword: _newPwCtrl.text,
      );
      if (!mounted) return;
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      setState(() => _understood = false);
      _snack(l.successMasterPasswordChanged);
      Navigator.pop(context);
    } on WrongMasterPasswordException {
      if (mounted) _snack(l.errorWrongMasterPassword);
    } on MasterPasswordChangeException {
      if (mounted) _snack(l.errorMasterPasswordChangeFailed);
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(
            text: l.titleChangeMasterPassword, fontSize: 20, color: accent, glow: true),
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
        child: SafeArea(
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MasterPasswordWarningPanel(
                understood: _understood,
                enabled:    !_changing,
                onUnderstoodChanged: (v) => setState(() => _understood = v),
              ),
              const SizedBox(height: 16),
              ChangeMasterPasswordPanel(
                currentCtrl:   _currentPwCtrl,
                newCtrl:       _newPwCtrl,
                confirmCtrl:   _confirmPwCtrl,
                fieldsEnabled: _understood,
                loading:       _changing,
                onSubmit:      _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
