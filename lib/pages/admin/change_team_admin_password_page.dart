import 'package:flutter/material.dart';
import '../../services/role_credentials.dart'; // Team Admin

class ChangeTeamAdminPasswordPage extends StatefulWidget {
  const ChangeTeamAdminPasswordPage({super.key});

  @override
  State<ChangeTeamAdminPasswordPage> createState() => _ChangeTeamAdminPasswordPageState();
}

class _ChangeTeamAdminPasswordPageState extends State<ChangeTeamAdminPasswordPage> {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  void changePassword() async {
    final storedPassword = RoleCredentials.teamAdminPassword;

    if (oldController.text != storedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ancien mot de passe Team Admin incorrect')));
      return;
    } 

    if (newController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les nouveaux mots de passe ne correspondent pas')));
      return;
    }

    await RoleCredentials.updateTeamAdminPassword(newController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Mot de passe Team Admin modifié')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    oldController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Changer mot de passe Team Admin")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Ancien mot de passe"),
            ), 
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirmer nouveau mot de passe"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: changePassword, child: const Text("Valider")),
          ],
        ),
      ),
    );
  }
}
