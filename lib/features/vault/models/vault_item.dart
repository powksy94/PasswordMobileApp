// lib/models/vault_item.dart
class VaultItem {
  final String id;
  final String type;
  final String label;
  final String login;
  final String password;
  final String notes;
  final String icon;
  final String url;
  final String pin;
  final String? pinStrength;

  VaultItem({
    required this.id,
    required this.label,
    required this.login,
    required this.password,
    required this.notes,
    this.type = 'password',
    this.icon = 'lock',
    this.url  = '',
    this.pin  = '',
    this.pinStrength,
  });

  Map<String, dynamic> toJson() => {
        'id':       id,
        'type':     type,
        'label':    label,
        'login':    login,
        'password': password,
        'notes':    notes,
        'icon':     icon,
        'url':      url,
        'pin':      pin,
      };

  factory VaultItem.fromJson(Map<String, dynamic> m) => VaultItem(
        id:          m['id']       as String,
        type:        m['type']     as String? ?? 'password',
        label:       m['label']    as String,
        login:       m['login']    as String,
        password:    m['password'] as String,
        notes:       m['notes']    as String,
        icon:        m['icon']     as String? ?? 'lock',
        url:         m['url']      as String? ?? '',
        pin:         m['pin']      as String? ?? '',
        pinStrength: m['pinStrength'] as String?,
      );
}
