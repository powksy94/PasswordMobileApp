import 'package:flutter/material.dart';
import '../../../shared/widgets/animations/lock_close_animation.dart';
import '../../../shared/widgets/animations/typewriter_text.dart';
import '../../../l10n/app_localizations.dart';

class SignupSuccessPage extends StatefulWidget {
  const SignupSuccessPage({super.key});

  @override
  State<SignupSuccessPage> createState() => _SignupSuccessPageState();
}

class _SignupSuccessPageState extends State<SignupSuccessPage> {
  bool _line2Started = false;

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  static const _style = TextStyle(
    fontSize:      20,
    fontWeight:    FontWeight.bold,
    letterSpacing: 2,
    color:         Colors.cyanAccent,
    shadows: [
      Shadow(color: Colors.cyan,       blurRadius: 8),
      Shadow(color: Colors.blueAccent, blurRadius: 20),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LockCloseAnimation(
                size:  96,
                delay: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: 40),
              TypewriterText(
                text:       l.signupSuccessTitle.toUpperCase(),
                style:      _style,
                startDelay: const Duration(milliseconds: 1300),
                onComplete: () => setState(() => _line2Started = true),
              ),
              const SizedBox(height: 8),
              if (_line2Started)
                TypewriterText(
                  text:       l.signupSuccessSubtitle.toUpperCase(),
                  style:      _style.copyWith(
                    fontSize:      14,
                    letterSpacing: 1.5,
                    color:         Colors.cyanAccent.withValues(alpha: 0.8),
                  ),
                  onComplete: _navigateToLogin,
                )
              else
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
