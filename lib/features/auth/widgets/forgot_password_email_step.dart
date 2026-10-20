import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';

/// First step of "forgot password": the account email to send the code to.
class ForgotPasswordEmailStep extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailCtrl;
  final bool                  loading;
  final VoidCallback          onSubmit;

  const ForgotPasswordEmailStep({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPanel(
      width: double.infinity,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.bodyForgotPasswordEmail),
            const SizedBox(height: 14),
            TextFormField(
              controller:      emailCtrl,
              keyboardType:    TextInputType.emailAddress,
              autofillHints:   const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => loading ? null : onSubmit(),
              validator: (v) =>
                  v != null && v.contains('@') ? null : l.validatorEmailInvalid,
              decoration: InputDecoration(
                labelText:  l.labelEmail,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                child: loading
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.btnSendCode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
