import 'package:flutter/material.dart';
import '../generator/password_generator_page.dart';
import '../../services/vault_service.dart';
import '../../models/vault_item.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/neon_text.dart';
import '../../widgets/protected_page.dart'; // ← wrapper sécurité

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  List<VaultItem> items = [];
  final Map<String, bool> _showPassword = {};

  @override
  void initState() {
    super.initState();
    loadVault();
  }

  /// Charge tous les items du coffre depuis le serveur
  Future<void> loadVault() async {
    try {
      final loaded = await VaultService.loadFromServer();
      for (final item in loaded) {
        _showPassword.putIfAbsent(item.id, () => false);
      }
      if (mounted) setState(() => items = loaded);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement: $e")),
        );
      }
    }
  }

  /// Supprime un item par son ID
  Future<void> deleteItem(String id) async {
    await VaultService.deleteFromServer(id);
    await loadVault();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item supprimé")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ProtectedPage(
      requiresLogin: true, // 🔐 Vérification automatique admin/login
      child: Scaffold(
        appBar: AppBar(
          title: NeonText(
            text: 'Coffre-fort',
            fontSize: 22,
            color: isDark ? Colors.cyanAccent : Colors.blueAccent,
            glow: true,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter un mot de passe',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordGeneratorPage(
                      onVaultUpdated: loadVault,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.black, Colors.grey[900]!]
                  : [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: items.isEmpty
              ? Center(
                  child: NeonText(
                    text: 'Coffre vide',
                    fontSize: 20,
                    color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                    glow: true,
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final id = item.id;
                    final icon = VaultService.getVaultIcon(item.icon);
                    final label = item.label;
                    final password = item.password;
                    final notes = item.notes;
                    final isVisible = _showPassword[id] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GlassPanel(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  icon,
                                  color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: NeonText(
                                    text: label,
                                    fontSize: 18,
                                    color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                                    glow: true,
                                    bold: true,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isVisible ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.orangeAccent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword[id] = !isVisible;
                                    });
                                  },
                                  tooltip: isVisible ? "Masquer le mot de passe" : "Afficher le mot de passe",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => deleteItem(id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              isVisible ? password : '●●●●●●●●',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  notes,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
