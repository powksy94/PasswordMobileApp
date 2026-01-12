import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'role_manager.dart';
import 'package:password_mobile_app/services/auth_service.dart';

class RouteGuard {
  static Future<bool> canAccess(
    BuildContext context, {
    bool requiresLogin = true,
    bool adminOnly = false,
  }) async {
    final roleManager = Provider.of<RoleManager>(context, listen: false);
    final isAdmin = roleManager.isAdmin;

    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn && requiresLogin) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return false;
    }

    if (adminOnly && !isAdmin) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return false;
    }

    return true;
  }
}
