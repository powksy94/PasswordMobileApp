import 'package:flutter/material.dart';
import '../../services/update_service.dart';
import 'glass_panel.dart';
import 'neon_text.dart';

void showUpdateDialog(BuildContext context, String apkUrl) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        width:   320,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              text:     'Nouvelle mise à jour !',
              fontSize: 26,
              color:    accent,
              glow:     true,
            ),
            const SizedBox(height: 20),
            Text(
              'Une nouvelle version est disponible. '
              'Téléchargez-la pour bénéficier des dernières fonctionnalités.',
              style: TextStyle(
                color:      isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w400,
                shadows: [
                  Shadow(
                    color:      accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  child: const Text('Plus tard'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    UpdateService.downloadAndInstallApk(
                        context: context, url: apkUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  child: const Text('Mettre à jour'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
