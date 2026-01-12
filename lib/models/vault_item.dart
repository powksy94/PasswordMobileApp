// lib/models/vault_item.dart
class VaultItem {
  final String id;
  final String label;
  final String login;
  final String password;
  final String notes;
  final String icon;

  VaultItem({
    required this.id,
    required this.label,
    required this.login,
    required this.password,
    required this.notes,
    this.icon = 'lock',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'login': login,
        'password': password,
        'notes': notes,
        'icon': icon,
      };

  factory VaultItem.fromJson(Map<String, dynamic> m) => VaultItem(
        id: m['id'] as String,
        label: m['label'] as String,
        login: m['login'] as String,
        password: m['password'] as String,
        notes: m['notes'] as String,
        icon: m['icon'] as String? ?? 'lock',
      );
}
