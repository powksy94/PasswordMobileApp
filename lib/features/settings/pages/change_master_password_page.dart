import 'package:flutter/material.dart';
import '../../vault/services/vault_reencrypt_service.dart';
import '../../auth/services/biometric_unlock_service.dart';
import '../../auth/services/master_key_service.dart';
import '../../../shared/widgets/common/app_page_scaffold.dart';
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
      await VaultReencryptService.changeMasterPassword(
        oldMasterPassword: _currentPwCtrl.text,
        newMasterPassword: _newPwCtrl.text,
      );
      if (!mounted) return;

      final key = MasterKeyService.getMasterKey();
      if (key != null) {
        await BiometricUnlockService.resyncAfterKeyChange(
          key,
          promptTitle: l.biometricReason,
          cancelLabel: l.btnCancel,
        );
        if (!mounted) return;
      }

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
    final l = AppLocalizations.of(context)!;

    return AppPageScaffold(
      title:    l.titleChangeMasterPassword,
      safeArea: true,
      body: ListView(
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
    );
  }
}
