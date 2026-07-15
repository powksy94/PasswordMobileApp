import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Retourne un dossier privé à l'app pour y écrire un export avant de le
/// partager via [Share.shareXFiles] (voir vault_export_actions.dart).
///
/// On n'écrit plus directement dans le dossier public `Download/` : sous
/// scoped storage (Android 10+), un `File` brut construit à partir d'un
/// chemin deviné échoue silencieusement ou lève, sans permission
/// `MANAGE_EXTERNAL_STORAGE`. Passer par le partage système laisse
/// l'utilisateur choisir la vraie destination (Fichiers, Drive, e-mail…)
/// via une UI que l'OS autorise sans permission supplémentaire.
Future<Directory> getExportScratchDirectory() => getTemporaryDirectory();
