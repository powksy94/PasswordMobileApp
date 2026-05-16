import 'package:flutter/material.dart';

class UserRoleTile extends StatelessWidget {
  final String email;
  final String currentRole;
  final void Function(String newRole) onRoleChanged;

  static const _validRoles = ['user', 'admin', 'team_admin'];

  const UserRoleTile({
    super.key,
    required this.email,
    required this.currentRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeRole =
        _validRoles.contains(currentRole) ? currentRole : 'user';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading:  const Icon(Icons.person),
        title:    Text(email, overflow: TextOverflow.ellipsis),
        subtitle: Text(safeRole),
        trailing: DropdownButton<String>(
          value:     safeRole,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'user',       child: Text('User')),
            DropdownMenuItem(value: 'admin',      child: Text('Admin')),
            DropdownMenuItem(value: 'team_admin', child: Text('Team Admin')),
          ],
          onChanged: (newRole) {
            if (newRole != null && newRole != currentRole) {
              onRoleChanged(newRole);
            }
          },
        ),
      ),
    );
  }
}
