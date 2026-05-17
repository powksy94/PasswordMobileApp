import 'package:flutter/material.dart';
import '../../models/vault_item.dart';
import '../../services/vault_export_service.dart';
import '../../services/biometric_export_service.dart';

/// Affiche le dialogue de choix du format d'export et orchestre les actions.

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
    builder: (_) => SimpleDialog(
      title: const Text('Exporter le vault'),
      children: [
        _ExportOption(
          icon:     Icons.fingerprint,
          color:    Colors.cyanAccent,
          title:    'Chiffré — biométrie',
          subtitle: 'Uniquement sur cet appareil.\nRequiert empreinte ou PIN.',
          onTap: () {
            Navigator.pop(context);
            exportVaultBiometric(context, items);
          },
        ),
        _ExportOption(
          icon:     Icons.vpn_key,
          color:    Colors.greenAccent,
          title:    'Chiffré — portable',
          subtitle: 'Tout appareil avec votre mot de passe maître.',
          onTap: () {
            Navigator.pop(context);
            exportVaultPortable(context, items);
          },
        ),
        _ExportOption(
          icon:     Icons.description,
          color:    Colors.orangeAccent,
          title:    'JSON — texte clair',
          subtitle: '⚠️ Mots de passe lisibles par tous.',
          onTap: () {
            Navigator.pop(context);
            exportVaultJson(context, items);
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    ),
  );
}

// ── Snackbar de confirmation ──────────────────────────────────────────────────

void _snackSuccess(BuildContext context, String path) {
  final filename = path.split('/').last;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:  Text('✅ Enregistré dans Téléchargements : $filename'),
      duration: const Duration(seconds: 5),
    ),
  );
}

// ── Actions d'export ──────────────────────────────────────────────────────────

Future<void> exportVaultBiometric(
  BuildContext context,
  List<VaultItem> items,
) async {
  final available = await BiometricExportService.isAvailable();
  if (!context.mounted) return;

  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Biométrie non disponible — utilisez l\'export portable')),
    );
    return;
  }

  try {
    final path = await BiometricExportService.exportEncrypted(items);
    if (!context.mounted) return;
    if (path == null) return;
    _snackSuccess(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur export : $e')));
    }
  }
}

Future<void> exportVaultPortable(
  BuildContext context,
  List<VaultItem> items,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title:   const Text('Export portable'),
      content: const Text(
        'Le fichier sera chiffré avec votre mot de passe maître.\n\n'
        'Il sera enregistré dans votre dossier Téléchargements.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Exporter'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final path = await VaultExportService.exportPortable(items);
    if (!context.mounted) return;
    _snackSuccess(context, path);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur export : $e')));
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
        'Il sera enregistré dans votre dossier Téléchargements.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Exporter'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final path = await VaultExportService.exportToJson(items);
    if (!context.mounted) return;
    final filename = path.split('/').last;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Text('✅ Enregistré dans Téléchargements : $filename'),
        duration: const Duration(seconds: 5),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur export : $e')));
    }
  }
}

// ── Widget interne ────────────────────────────────────────────────────────────

class _ExportOption extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       title;
  final String       subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
