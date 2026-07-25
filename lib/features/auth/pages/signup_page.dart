import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../widgets/signup_step1.dart';
import '../widgets/signup_step2.dart';
import '../services/auth_service.dart';
import '../services/biometric_unlock_service.dart';
import '../services/master_key_service.dart';
import '../../settings/services/settings_service.dart';
import '../utils/api_error.dart';
import '../../../l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey1            = GlobalKey<FormState>();
  final _formKey2            = GlobalKey<FormState>();
  final _emailCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _masterPwCtrl        = TextEditingController();
  final _confirmMasterPwCtrl = TextEditingController();

  int  _step         = 0;
  bool _showTutorial = true;
  bool _loading      = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _masterPwCtrl.dispose();
    _confirmMasterPwCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKey1.currentState!.validate()) return;
    setState(() { _step = 1; _showTutorial = true; });
  }

  void _prevStep() => setState(() { _step = 0; _showTutorial = false; });

  Future<void> _submit() async {
    if (!_formKey2.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _masterPwCtrl.text,
      );
      if (!mounted) return;

      final l = AppLocalizations.of(context)!;
      final key = MasterKeyService.getMasterKey();
      if (key != null) {
        await BiometricUnlockService.maybeAutoEnable(
          key,
          biometricEnabledSetting: await SettingsService.getBiometricEnabled(),
          promptTitle: l.biometricReason,
          cancelLabel: l.btnCancel,
        );
        if (!mounted) return;
      }

      Navigator.pushReplacementNamed(context, '/signup-success');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GlassPanel(
            width:   350,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeonText(text: AppLocalizations.of(context)!.signupTitle, fontSize: 26, color: accent, glow: true),
                const SizedBox(height: 16),

                // Barre de progression
                Row(
                  children: List.generate(2, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 1 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color:        i <= _step ? accent : accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Étape ${_step + 1} / 2',
                        style: TextStyle(
                          fontSize: 12,
                          color:    isDark ? Colors.white38 : Colors.black38,
                        )),
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? SignupStep1(
                          key:                  const ValueKey(0),
                          formKey:              _formKey1,
                          emailCtrl:            _emailCtrl,
                          passwordCtrl:         _passwordCtrl,
                          confirmPasswordCtrl:  _confirmPasswordCtrl,
                          showTutorial:         _showTutorial,
                          onDismissTutorial:    () => setState(() => _showTutorial = false),
                          onNext:               _nextStep,
                        )
                      : SignupStep2(
                          key:                  const ValueKey(1),
                          formKey:              _formKey2,
                          masterPwCtrl:         _masterPwCtrl,
                          confirmMasterPwCtrl:  _confirmMasterPwCtrl,
                          showTutorial:         _showTutorial,
                          loading:              _loading,
                          onDismissTutorial:    () => setState(() => _showTutorial = false),
                          onSubmit:             _submit,
                          onBack:               _prevStep,
                        ),
                ),

                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child:     Text(AppLocalizations.of(context)!.btnAlreadyAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
