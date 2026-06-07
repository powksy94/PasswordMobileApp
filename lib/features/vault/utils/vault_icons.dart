import 'package:flutter/material.dart';

/// Associe le nom d'icône stocké sur un [VaultItem] à son [IconData] —
/// logique partagée entre les cartes du coffre et les listes de santé.
class VaultIcons {
  static IconData forName(String iconName) {
    switch (iconName) {
      case 'email':       return Icons.email;
      case 'wifi':        return Icons.wifi;
      case 'credit_card': return Icons.credit_card;
      case 'person':      return Icons.person;
      case 'vpn_key':     return Icons.vpn_key;
      case 'phone':       return Icons.phone;
      case 'computer':    return Icons.computer;
      case 'cloud':       return Icons.cloud;
      default:            return Icons.lock;
    }
  }
}
