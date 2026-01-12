import 'package:flutter/material.dart';
import '../services/route_guard.dart';

/// Widget wrapper pour sécuriser une page
class ProtectedPage extends StatefulWidget {
  final Widget child;
  final bool requiresLogin; // Accès réservé aux utilisateurs connectés
  final bool adminOnly;     // Accès réservé aux admins

  const ProtectedPage({
    super.key,
    required this.child,
    this.requiresLogin = true,
    this.adminOnly = false,
  });

  @override
  State<ProtectedPage> createState() => _ProtectedPageState();
}

class _ProtectedPageState extends State<ProtectedPage> {
  bool _allowed = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final allowed = await RouteGuard.canAccess(
      context,
      requiresLogin: widget.requiresLogin,
      adminOnly: widget.adminOnly,
    );

    if (mounted) {
      setState(() {
        _allowed = allowed;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      // Loader pendant la vérification
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_allowed) {
      // Redirection déjà gérée par RouteGuard
      return const SizedBox.shrink();
    }

    // Accès autorisé → affiche la page enfant
    return widget.child;
  }
}
