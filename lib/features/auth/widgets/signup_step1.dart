import 'package:flutter/material.dart';
import './password_section.dart';
import './tutorial_bubble.dart';
import '../../../l10n/app_localizations.dart';

class SignupStep1 extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final bool                  showTutorial;
  final VoidCallback          onDismissTutorial;
  final VoidCallback          onNext;

  const SignupStep1({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    required this.showTutorial,
    required this.onDismissTutorial,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill   = isDark ? Colors.white10 : Colors.black12;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TutorialBubble(
            icon:      Icons.person_outline,
            title:     l.signupStep1Title,
            body:      l.tutorialStep1Body,
            visible:   showTutorial,
            onDismiss: onDismissTutorial,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showTutorial
                ? const SizedBox.shrink()
                : Column(
                    key: const ValueKey('step1-form'),
                    children: [
                      TextFormField(
                        controller:   emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : l.validatorEmailInvalid,
                        decoration: InputDecoration(
                          labelText:  l.labelEmail,
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled:     true,
                          fillColor:  fill,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PasswordSection(
                        label:             l.labelAccountPassword,
                        controller:        passwordCtrl,
                        confirmController: confirmPasswordCtrl,
                        minLength:         6,
                        confirmValidator:  (v) => v == passwordCtrl.text
                            ? null
                            : l.validatorPasswordMismatch,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onNext,
                          icon:  const Icon(Icons.arrow_forward),
                          label: Text(l.btnNext),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
