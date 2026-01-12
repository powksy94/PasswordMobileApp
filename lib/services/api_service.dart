import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart'; // ← pour Clipboard
import '../../services/password_generator.dart';
import '../../services/vault_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/password_strength_bar.dart';
import '../../widgets/neon_text.dart';
import '../../widgets/protected_page.dart';

class PasswordGeneratorPage extends StatefulWidget {
  final VoidCallback? onVaultUpdated;

  const PasswordGeneratorPage({super.key, this.onVaultUpdated});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  int length = 16;
  bool useLower = true,
      useUpper = true,
      useDigits = true,
      useSpecials = true,
      requireAll = true;
  bool showPassword = false;
  String exclude = "";
  String password = "";

  final TextEditingController labelController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    password = "";
    labelController.clear();
    notesController.clear();
  }

  @override
  void dispose() {
    password = "";
    labelController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void generate() {
    setState(() {
      password = PasswordGenerator.generate(
        length: length,
        useLower: useLower,
        useUpper: useUpper,
        useDigits: useDigits,
        useSpecials: useSpecials,
        requireAllTypes: requireAll,
        exclude: exclude,
      );
      showPassword = false;
    });
  }

  Future<void> addToVault() async {
    if (labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez entrer un label pour le mot de passe.")),
      );
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await VaultService.writeItem(
      id: id,
      label: labelController.text,
      password: password,
      notes: notesController.text,
      icon: 'lock',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mot de passe ajouté au coffre !")),
    );

    widget.onVaultUpdated?.call();

    password = "";
    labelController.clear();
    notesController.clear();
    showPassword = false;
    setState(() {});
  }

  void copyPassword() {
    if (password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mot de passe copié dans le presse-papier")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ProtectedPage(
      requiresLogin: true,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              GlassPanel(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        password.isEmpty
                            ? "Mot de passe vide"
                            : (showPassword ? password : '●●●●●●●●'),
                        style: TextStyle(
                          fontSize: 20,
                          color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                        ),
                      ),
                    ),
                    if (password.isNotEmpty) ...[
                      IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        tooltip: showPassword
                            ? "Masquer le mot de passe"
                            : "Afficher le mot de passe",
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.greenAccent),
                        onPressed: copyPassword,
                        tooltip: "Copier le mot de passe",
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              PasswordStrengthBar(password: password),
              const SizedBox(height: 12),
              NeonText(
                text: "Longueur : $length",
                fontSize: 16,
                color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                glow: true,
              ),
              Slider(
                value: length.toDouble(),
                min: 4,
                max: 64,
                divisions: 60,
                label: "$length",
                activeColor: isDark ? Colors.cyanAccent : Colors.blueAccent,
                inactiveColor:
                    (isDark ? Colors.cyanAccent : Colors.blueAccent)
                        .withOpacity(0.3),
                onChanged: (v) => setState(() => length = v.toInt()),
              ),
              CheckboxListTile(
                value: useLower,
                onChanged: (v) => setState(() => useLower = v!),
                title: Text("Minuscules",
                    style:
                        TextStyle(color: isDark ? Colors.cyanAccent : Colors.blueAccent)),
              ),
              CheckboxListTile(
                value: useUpper,
                onChanged: (v) => setState(() => useUpper = v!),
                title: Text("Majuscules",
                    style:
                        TextStyle(color: isDark ? Colors.cyanAccent : Colors.blueAccent)),
              ),
              CheckboxListTile(
                value: useDigits,
                onChanged: (v) => setState(() => useDigits = v!),
                title: Text("Chiffres",
                    style:
                        TextStyle(color: isDark ? Colors.cyanAccent : Colors.blueAccent)),
              ),
              CheckboxListTile(
                value: useSpecials,
                onChanged: (v) => setState(() => useSpecials = v!),
                title: Text("Spéciaux",
                    style:
                        TextStyle(color: isDark ? Colors.cyanAccent : Colors.blueAccent)),
              ),
              TextField(
                controller: labelController,
                decoration:
                    const InputDecoration(labelText: "Label du mot de passe"),
              ),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: "Notes (optionnel)"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.cyanAccent : Colors.blueAccent,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                ),
                onPressed: generate,
                icon: const Icon(Icons.refresh),
                label: const Text("Générer"),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.greenAccent : Colors.green,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                ),
                onPressed: addToVault,
                icon: const FaIcon(FontAwesomeIcons.vault),
                label: const Text("Ajouter au coffre"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
