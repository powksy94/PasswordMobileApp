import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'biometric_service.dart';

/// Gère Firebase Cloud Messaging :
/// - Enregistrement du token FCM sur le backend
/// - Réception des notifications d'approbation admin
class FcmService {
  static final _fcm = FirebaseMessaging.instance;

  // ── Initialisation ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    // Demande la permission (Android 13+)
    await _fcm.requestPermission(
      alert:         true,
      badge:         true,
      sound:         true,
      provisional:   false,
    );

    // Enregistre le token FCM sur le backend après connexion
    await _registerToken();

    // Rafraîchit le token si Firebase le renouvelle
    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToServer);
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  static Future<void> _registerToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _sendTokenToServer(token);
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await AuthService.getToken();
      if (authToken == null) return;
      await ApiService().registerFcmToken(authToken, token);
    } catch (_) {}
  }

  // ── Handler des notifications foreground ─────────────────────────────────

  static void listenForeground(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (!context.mounted) return;
      final data = message.data;
      if (data['type'] == 'admin_approval_request') {
        _showApprovalDialog(context, data['sessionId'] ?? '');
      }
    });
  }

  // ── Dialog d'approbation ──────────────────────────────────────────────────

  static void _showApprovalDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AdminApprovalDialog(sessionId: sessionId),
    );
  }
}

// ── Widget dialog d'approbation ───────────────────────────────────────────────

class _AdminApprovalDialog extends StatefulWidget {
  final String sessionId;
  const _AdminApprovalDialog({required this.sessionId});

  @override
  State<_AdminApprovalDialog> createState() => _AdminApprovalDialogState();
}

class _AdminApprovalDialogState extends State<_AdminApprovalDialog> {
  bool _loading = false;

  Future<void> _respond(bool approved) async {
    // Si approbation → vérifie l'empreinte avant d'envoyer
    if (approved) {
      final ok = await BiometricService.authenticate(
        reason: 'Confirmez votre identité pour approuver la connexion admin',
      );
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empreinte non reconnue — approbation annulée')),
          );
        }
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      await ApiService().respondAdminSession(token, widget.sessionId, approved);
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.admin_panel_settings, color: Colors.orangeAccent),
          SizedBox(width: 10),
          Text('Connexion admin'),
        ],
      ),
      content: const Text(
        'Une tentative de connexion au panneau d\'administration vient d\'être effectuée.\n\n'
        'Êtes-vous à l\'origine de cette connexion ?',
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => _respond(false),
          child: const Text('Refuser', style: TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : () => _respond(true),
          child: _loading
              ? const SizedBox(
                  height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Approuver'),
        ),
      ],
    );
  }
}
