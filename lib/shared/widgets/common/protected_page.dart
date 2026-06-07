import 'package:flutter/material.dart';
import '../../services/route_guard.dart';

class ProtectedPage extends StatefulWidget {
  final Widget child;
  final bool requiresLogin;
  final bool adminOnly;

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
  bool _allowed  = false;
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
      adminOnly:     widget.adminOnly,
    );
    if (mounted) {
      setState(() {
        _allowed  = allowed;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_allowed) return const SizedBox.shrink();
    return widget.child;
  }
}
