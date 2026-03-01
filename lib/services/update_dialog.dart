import 'package:flutter/material.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_text.dart';
import 'update_service.dart';

void showUpdateDialog(BuildContext context, String apkUrl) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          width: 320,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonText(
                text: "Nouvelle mise à jour !",
                fontSize: 26,
                color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                glow: true, // effet neon glow
              ),
              const SizedBox(height: 20),
              Text(
                "Une nouvelle version est disponible. "
                "Téléchargez-la pour bénéficier des dernières fonctionnalités et améliorations.",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      color: isDark
                          ? Colors.cyanAccent.withValues(alpha:0.3)
                          : Colors.blueAccent.withValues(alpha:0.2),
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: isDark
                          ? Colors.cyanAccent.withValues(alpha:0.4)
                          : Colors.blueAccent.withValues(alpha:0.3),
                      elevation: 6,
                    ),
                    child: const Text("Plus tard"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      UpdateService.downloadAndInstallApk(
                        context: context,
                        url: apkUrl,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.cyanAccent : Colors.blueAccent,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: isDark
                          ? Colors.cyanAccent.withValues(alpha:0.6)
                          : Colors.blueAccent.withValues(alpha:0.5),
                      elevation: 8,
                    ),
                    child: const Text("Mettre à jour"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
