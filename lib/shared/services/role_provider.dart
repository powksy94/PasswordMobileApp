import 'dart:async';
import 'package:flutter/material.dart';

enum UserRole { user, admin, teamAdmin }

/// Single source of truth for the current user's role.
///
/// Replaces the former [RoleManager] / [AdminProvider] / [TeamAdminProvider] trio.
/// - The admin role expires automatically after [_adminTimeout] of inactivity.
/// - No persistence: restoration at startup is done by [AuthService].
class RoleProvider extends ChangeNotifier {
  UserRole _role = UserRole.user;
  Timer?   _adminTimer;

  static const _adminTimeout = Duration(minutes: 5);

  UserRole get role        => _role;
  bool get isAdmin         => _role == UserRole.admin;
  bool get isTeamAdmin     => _role == UserRole.teamAdmin;
  bool get isUser          => _role == UserRole.user;

  /// Sets the role. Starts the expiry timer for [UserRole.admin].
  void setRole(UserRole role) {
    _adminTimer?.cancel();
    _role = role;
    if (role == UserRole.admin) _startTimer();
    notifyListeners();
  }

  /// Switches back to [UserRole.user] and cancels the timer.
  void deactivate() => setRole(UserRole.user);

  void _startTimer() {
    _adminTimer = Timer(_adminTimeout, () {
      _role = UserRole.user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _adminTimer?.cancel();
    super.dispose();
  }
}
