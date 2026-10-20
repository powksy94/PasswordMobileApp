import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import '../widgets/forgot_password_email_step.dart';
import '../widgets/forgot_password_code_step.dart';
import '../../../shared/widgets/common/app_page_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// "Forgot password": email -> emailed code + new login password. Opened
/// from the login page with the email already typed there (route argument);
/// pops with the email on success so the login page can prefill it.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailFormKey  = GlobalKey<FormState>();
  final _codeFormKey   = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _codeCtrl      = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _codeSent = false;
  bool _loading  = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final initialEmail = ModalRoute.of(context)?.settings.arguments;
    if (initialEmail is String) _emailCtrl.text = initialEmail;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode({bool resend = false}) async {
    if (!resend && !_emailFormKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await PasswordResetService.requestCode(_emailCtrl.text);
      if (!mounted) return;
      setState(() => _codeSent = true);
      if (resend) _snack(l.snackCodeResent);
    } catch (e) {
      if (mounted) _snack(PasswordResetService.errorMessage(l, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    if (!_codeFormKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await PasswordResetService.confirm(
        email:       _emailCtrl.text,
        code:        _codeCtrl.text,
        newPassword: _newPwCtrl.text,
      );
      if (!mounted) return;
      _snack(l.successPasswordReset);
      Navigator.pop(context, _emailCtrl.text.trim());
    } catch (e) {
      if (mounted) _snack(PasswordResetService.errorMessage(l, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AppPageScaffold(
      title:    l.titleForgotPassword,
      safeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _codeSent
            ? ForgotPasswordCodeStep(
                formKey:       _codeFormKey,
                email:         _emailCtrl.text.trim(),
                codeCtrl:      _codeCtrl,
                newPwCtrl:     _newPwCtrl,
                confirmPwCtrl: _confirmPwCtrl,
                loading:       _loading,
                onSubmit:      _confirm,
                onResend:      () => _sendCode(resend: true),
              )
            : ForgotPasswordEmailStep(
                formKey:   _emailFormKey,
                emailCtrl: _emailCtrl,
                loading:   _loading,
                onSubmit:  _sendCode,
              ),
      ),
    );
  }
}
