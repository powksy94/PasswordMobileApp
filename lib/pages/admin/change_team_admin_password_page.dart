import 'package:flutter/material.dart';
import '../../services/admin_password_service.dart';

class ChangeTeamAdminPasswordPage extends StatefulWidget {
  const ChangeTeamAdminPasswordPage({super.key});

  @override
  State<ChangeTeamAdminPasswordPage> createState() =>
      _ChangeTeamAdminPasswordPageState();
}

class _ChangeTeamAdminPasswordPageState
    extends State<ChangeTeamAdminPasswordPage> {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  // null = chargement, true = aucun password (création), false = password existant (modification)
  bool? _isCreation;

  @override
  void initState() {
    super.initState();
    _checkPasswordExists();
  }

  Future<void> _checkPasswordExists() async {
    final stored = await AdminPasswordService.getTeamAdminPassword();
    if (mounted) setState(() => _isCreation = stored == null);
  }

  void changePassword() async {
    if (_isCreation == null) return;

    if (_isCreation == false) {
      final stored = await AdminPasswordService.getTeamAdminPassword();
      if (oldController.text != stored) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Ancien mot de passe Team Admin incorrect')));
        }
        return;
      }
    }

    if (newController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Le mot de passe ne peut pas être vide')));
      }
      return;
    }

    if (newController.text != confirmController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Les nouveaux mots de passe ne correspondent pas')));
      }
      return;
    }

    await AdminPasswordService.setTeamAdminPassword(newController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isCreation!
              ? 'Mot de passe Team Admin créé avec succès'
              : 'Mot de passe Team Admin modifié')));
      Navigator.pop(context);
    }
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
    if (_isCreation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreation!
            ? 'Créer mot de passe Team Admin'
            : 'Changer mot de passe Team Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isCreation!)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Aucun mot de passe Team Admin n\'existe encore. Définissez-en un.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 14),
                ),
              ),
            if (!_isCreation!)
              TextField(
                controller: oldController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Ancien mot de passe'),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: newController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirmer nouveau mot de passe'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: changePassword,
              child: Text(_isCreation! ? 'Créer' : 'Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
