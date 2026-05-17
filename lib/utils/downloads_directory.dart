import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Retourne le dossier Téléchargements visible depuis le gestionnaire de fichiers.
/// Sur Android : /storage/emulated/0/Download
/// Fallback : dossier documents interne de l'app.
Future<Directory> getDownloadsDirectory() async {
  final extDir = await getExternalStorageDirectory();
  if (extDir != null) {
    final root      = extDir.path.split('/Android/')[0];
    final downloads = Directory('$root/Download');
    if (await downloads.exists()) return downloads;
  }
  return getApplicationDocumentsDirectory();
}
