import 'package:flutter/material.dart';
import '../../services/admin_password_service.dart';

class ChangeAdminPasswordPage extends StatefulWidget {
  const ChangeAdminPasswordPage({super.key});

  @override
  State<ChangeAdminPasswordPage> createState() => _ChangeAdminPasswordPageState();
}

class _ChangeAdminPasswordPageState extends State<ChangeAdminPasswordPage> {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  void changePassword() async {
    final correct = await AdminPasswordService.verifyPassword(oldController.text);
    if (!mounted) return;

    if (!correct) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ancien mot de passe incorrect')));
      return;
    }
    if (newController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les nouveaux mots de passe ne correspondent pas')));
      return;
    }
    await AdminPasswordService.setPassword(newController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Mot de passe admin modifié')));
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
      appBar: AppBar(title: const Text("Changer mot de passe admin")),
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
