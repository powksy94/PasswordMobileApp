import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'role_provider.dart';
import 'auth_service.dart';

class RouteGuard {
  static Future<bool> canAccess(
    BuildContext context, {
    bool requiresLogin = true,
    bool adminOnly     = false,
  }) async {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isLoggedIn   = await AuthService.isLoggedIn();

    if (!isLoggedIn && requiresLogin) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return false;
    }

    if (adminOnly && !roleProvider.isAdmin) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return false;
    }

    return true;
  }
}
