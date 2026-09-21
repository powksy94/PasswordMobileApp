import 'package:flutter/material.dart';

/// Maps the icon name stored on a [VaultItem] to its [IconData]:
/// logic shared between the vault cards and the health lists.
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
