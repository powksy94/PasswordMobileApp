import 'dart:async';
import 'package:flutter/material.dart';

enum UserRole { user, admin, teamAdmin }

/// Source unique de vérité pour le rôle de l'utilisateur courant.
///
/// Remplace l'ancien trio [RoleManager] / [AdminProvider] / [TeamAdminProvider].
/// - Le rôle admin expire automatiquement après [_adminTimeout] d'inactivité.
/// - Pas de persistance : la restauration au démarrage est faite par [AuthService].
class RoleProvider extends ChangeNotifier {
  UserRole _role = UserRole.user;
  Timer?   _adminTimer;

  static const _adminTimeout = Duration(minutes: 5);

  UserRole get role        => _role;
  bool get isAdmin         => _role == UserRole.admin;
  bool get isTeamAdmin     => _role == UserRole.teamAdmin;
  bool get isUser          => _role == UserRole.user;

  /// Définit le rôle. Lance le timer d'expiration pour [UserRole.admin].
  void setRole(UserRole role) {
    _adminTimer?.cancel();
    _role = role;
    if (role == UserRole.admin) _startTimer();
    notifyListeners();
  }

  /// Repasse en [UserRole.user] et annule le timer.
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
