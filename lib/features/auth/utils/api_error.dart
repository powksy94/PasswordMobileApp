import 'package:dio/dio.dart';

/// Extrait un message lisible depuis une erreur Dio ou une exception générique.
String apiErrorMessage(dynamic error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final msg = (data['error'] ?? data['message']) as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return _httpMessage(error.response?.statusCode);
  }
  return error.toString();
}

String _httpMessage(int? status) {
  switch (status) {
    case 400: return 'Requête invalide.';
    case 401: return 'Email ou mot de passe de connexion incorrect.';
    case 403: return 'Accès refusé.';
    case 404: return 'Compte introuvable.';
    case 409: return 'Cet email est déjà utilisé.';
    case 422: return 'Données invalides.';
    case 500: return 'Erreur serveur — réessayez plus tard.';
    default:  return 'Erreur réseau (${status ?? "inconnue"}).';
  }
}
