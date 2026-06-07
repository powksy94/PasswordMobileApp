import 'package:flutter/material.dart';
import './password_section.dart';
import './tutorial_bubble.dart';
import '../../../l10n/app_localizations.dart';

class SignupStep2 extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController masterPwCtrl;
  final TextEditingController confirmMasterPwCtrl;
  final bool                  showTutorial;
  final bool                  loading;
  final VoidCallback          onDismissTutorial;
  final VoidCallback          onSubmit;
  final VoidCallback          onBack;

  const SignupStep2({
    super.key,
    required this.formKey,
    required this.masterPwCtrl,
    required this.confirmMasterPwCtrl,
    required this.showTutorial,
    required this.loading,
    required this.onDismissTutorial,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TutorialBubble(
            icon:      Icons.lock_outline,
            title:     l.signupStep2Title,
            body:      l.tutorialStep2Body,
            visible:   showTutorial,
            onDismiss: onDismissTutorial,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showTutorial
                ? const SizedBox.shrink()
                : Column(
                    key: const ValueKey('step2-form'),
                    children: [
                      PasswordSection(
                        label:             l.labelMasterPassword,
                        controller:        masterPwCtrl,
                        confirmController: confirmMasterPwCtrl,
                        minLength:         8,
                        showToggle:        true,
                        withInfoIcon:      true,
                        warningText:       l.warningMasterPassword,
                        confirmValidator:  (v) => v == masterPwCtrl.text
                            ? null
                            : l.validatorMasterPasswordMismatch,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : onSubmit,
                          child: loading
                              ? const SizedBox(
                                  height: 18, width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(l.btnCreateAccount),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: onBack,
                        child:     Text(l.btnBack),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
