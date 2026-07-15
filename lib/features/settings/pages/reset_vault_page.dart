import 'package:flutter/material.dart';
import '../../auth/services/master_key_service.dart';
import '../../vault/services/vault_service.dart';
import '../widgets/vault_reset_warning_panel.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

class ResetVaultPage extends StatefulWidget {
  const ResetVaultPage({super.key});

  @override
  State<ResetVaultPage> createState() => _ResetVaultPageState();
}

class _ResetVaultPageState extends State<ResetVaultPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _understood  = false;
  bool _loading     = false;
  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    if (_newCtrl.text.length < 6) { _snack(l.validatorMinChars); return; }
    if (_newCtrl.text != _confirmCtrl.text) { _snack(l.validatorMasterPasswordMismatch); return; }

    setState(() => _loading = true);
    try {
      // Une action aussi destructrice et irréversible exige de reprouver la
      // possession du mot de passe maître actuel (comme pour son changement),
      // pour éviter qu'un téléphone déverrouillé et laissé sans surveillance
      // permette de tout effacer via une simple case à cocher.
      final validCurrent = await MasterKeyService.unlockWithMasterPassword(_currentCtrl.text);
      if (!validCurrent) {
        _snack(l.errorWrongMasterPassword);
        return;
      }

      await VaultService.purgeAll();
      final ok = await MasterKeyService.resetMasterKey(_newCtrl.text);
      if (!ok) throw Exception();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(l.successVaultReset),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) _snack(l.errorVaultResetFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: NeonText(text: l.titleResetVault, fontSize: 20, color: accent, glow: true),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              VaultResetWarningPanel(
                understood: _understood,
                onChanged:  (v) => setState(() => _understood = v),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity:  _understood ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: GlassPanel(
                  width: double.infinity,
                  child: Column(
                    children: [
                      TextField(
                        controller:  _currentCtrl,
                        enabled:     _understood,
                        obscureText: !_showCurrent,
                        decoration: InputDecoration(
                          labelText: l.labelCurrentMasterPassword,
                          border:    const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_showCurrent ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showCurrent = !_showCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller:  _newCtrl,
                        enabled:     _understood,
                        obscureText: !_showNew,
                        decoration: InputDecoration(
                          labelText: l.labelNewMasterPassword,
                          border:    const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_showNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showNew = !_showNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller:  _confirmCtrl,
                        enabled:     _understood,
                        obscureText: !_showConfirm,
                        decoration: InputDecoration(
                          labelText: l.labelConfirmNewMasterPassword,
                          border:    const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showConfirm = !_showConfirm),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_understood && !_loading) ? _submit : null,
                  icon: _loading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.delete_sweep, color: Colors.white),
                  label: Text(
                    _loading ? l.progressResettingVault : l.btnResetVault,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:         Colors.redAccent,
                    disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
