import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/widgets/common/neon_text.dart';
import '../../../shared/utils/password_policy.dart';
import '../widgets/change_password_panel.dart';
import '../../../l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _changingPw = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final l = AppLocalizations.of(context)!;
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      _snack(l.validatorPasswordMismatch);
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
    setState(() => _changingPw = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');
      await ApiService().changePassword(
          token, _currentPwCtrl.text, _newPwCtrl.text);
      if (!mounted) return;
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      _snack(l.successModified);
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _changingPw = false);
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
        title: NeonText(
            text: l.titleChangePassword, fontSize: 20, color: accent, glow: true),
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
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ChangePasswordPanel(
                currentCtrl: _currentPwCtrl,
                newCtrl:     _newPwCtrl,
                confirmCtrl: _confirmPwCtrl,
                loading:     _changingPw,
                onSubmit:    _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
