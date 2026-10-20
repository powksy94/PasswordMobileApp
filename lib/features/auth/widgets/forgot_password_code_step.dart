import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/utils/password_policy.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Second step of "forgot password": the emailed code and the new login
/// password. The code field is tagged `oneTimeCode` so the keyboard can
/// offer the received code when it detects it (iOS Mail, some Android
/// keyboards); otherwise it is typed, or pasted with the paste button.
class ForgotPasswordCodeStep extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final String                email;
  final TextEditingController codeCtrl;
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final bool                  loading;
  final VoidCallback          onSubmit;
  final VoidCallback          onResend;

  const ForgotPasswordCodeStep({
    super.key,
    required this.formKey,
    required this.email,
    required this.codeCtrl,
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.loading,
    required this.onSubmit,
    required this.onResend,
  });

  /// Reads the clipboard only on an explicit tap (no automatic read, which
  /// Android 12+ reports to the user) and keeps the digits, so that a
  /// copied "Code: 123 456" still works.
  Future<void> _pasteCode() async {
    final data   = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    codeCtrl.text = digits.length > 6 ? digits.substring(0, 6) : digits;
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted  = isDark ? Colors.white60 : Colors.black54;

    return GlassPanel(
      width: double.infinity,
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.bodyForgotPasswordCode(email)),
              const SizedBox(height: 14),
              TextFormField(
                controller:      codeCtrl,
                keyboardType:    TextInputType.number,
                autofillHints:   const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (v) =>
                    v != null && v.length == 6 ? null : l.validatorResetCode,
                decoration: InputDecoration(
                  labelText:  l.labelResetCode,
                  prefixIcon: const Icon(Icons.pin_outlined),
                  suffixIcon: IconButton(
                    icon:      const Icon(Icons.content_paste),
                    tooltip:   l.tooltipPasteCode,
                    onPressed: loading ? null : _pasteCode,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller:    newPwCtrl,
                obscureText:   true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) {
                  if (v == null || v.length < PasswordPolicy.minLength) return l.validatorMinChars;
                  if (!PasswordPolicy.meetsComplexity(v)) return l.validatorPasswordComplexity;
                  return null;
                },
                decoration: InputDecoration(
                  labelText:  l.labelNewPassword,
                  prefixIcon: const Icon(Icons.lock_reset),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller:  confirmPwCtrl,
                obscureText: true,
                validator: (v) =>
                    v == newPwCtrl.text ? null : l.validatorPasswordMismatch,
                decoration: InputDecoration(
                  labelText:  l.labelConfirmNewPassword,
                  prefixIcon: const Icon(Icons.lock_reset),
                ),
              ),
              const SizedBox(height: 12),
              Text(l.noteResetVault, style: TextStyle(fontSize: 12, color: muted)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : onSubmit,
                  child: loading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.btnResetPassword),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: loading ? null : onResend,
                  child: Text(l.btnResendCode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
