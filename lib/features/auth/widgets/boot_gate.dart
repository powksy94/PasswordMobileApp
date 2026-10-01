import 'package:flutter/material.dart';
import '../../../shared/services/autofill_bridge_service.dart';
import './splash_auth_gate.dart';
import '../../vault/pages/autofill_generate_page.dart';

/// First screen the app ever shows. Decides, before anything else, whether
/// this launch is a normal app open ([SplashAuthGate]'s usual login/lock/home
/// routing) or the authentication step of an Android autofill "generate a
/// new password" suggestion ([AutofillGeneratePage]). Kept separate from
/// [SplashAuthGate] so that widget's own responsibility (post-login routing)
/// stays unchanged.
class BootGate extends StatefulWidget {
  const BootGate({super.key});

  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final generateMode = await AutofillBridgeService.isGenerateMode();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => generateMode ? const AutofillGeneratePage() : const SplashAuthGate(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
