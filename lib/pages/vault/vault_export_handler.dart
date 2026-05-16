import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_export_service.dart';
import '../../services/biometric_export_service.dart';

/// Gère les dialogues et actions d'export du vault.
/// Toutes les fonctions reçoivent le [BuildContext] courant et la liste des items.
/// Les vérifications [context.mounted] sont faites avant chaque usage de context après await.

Future<void> showVaultExportDialog(
  BuildContext context,
  List<VaultItem> items,
) async {
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coffre vide — rien à exporter')),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title:   const Text('Exporter le vault'),
      content: const Text(
        '🔒  Chiffré (biométrie)\n'
        'Fichier .enc lisible uniquement sur cet appareil avec votre empreinte.\n\n'
        '📄  JSON (portable)\n'
        'Fichier lisible partout — mots de passe en clair.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            exportVaultJson(context, items);
          },
          child: const Text('JSON'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            exportVaultBiometric(context, items);
          },
          icon:  const Icon(Icons.fingerprint, size: 18),
          label: const Text('Chiffré'),
        ),
      ],
    ),
  );
}

Future<void> exportVaultBiometric(
  BuildContext context,
  List<VaultItem> items,
) async {
  final available = await BiometricExportService.isAvailable();
  if (!context.mounted) return;

  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Biométrie non disponible — utilisez l\'export JSON'),
      ),
    );
    return;
  }

  try {
    final path = await BiometricExportService.exportEncrypted(items);
    if (!context.mounted) return;
    if (path == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Text('Export chiffré : $path'),
        duration: const Duration(seconds: 6),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur export : $e')),
      );
    }
  }
}

Future<void> exportVaultJson(
  BuildContext context,
  List<VaultItem> items,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title:   const Text('Export JSON'),
      content: const Text(
        '⚠️ Ce fichier contiendra vos mots de passe en clair.\n\n'
        'Conservez-le dans un endroit sûr et supprimez-le après usage.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Exporter quand même'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final path = await VaultExportService.exportToJson(items);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Text('Exporté : $path'),
        duration: const Duration(seconds: 6),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur export : $e')),
      );
    }
  }
}
