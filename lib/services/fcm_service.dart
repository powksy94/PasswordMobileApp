import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'biometric_service.dart';

/// Gère Firebase Cloud Messaging :
/// - Enregistrement du token FCM
/// - Notifications d'approbation admin (connexion dashboard)
/// - Notifications d'approbation vault admin (accès au vault)
class FcmService {
  static final _fcm = FirebaseMessaging.instance;

  static const _channelId   = 'admin_auth';
  static const _channelName = 'Approbations admin';

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // ── Initialisation ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    await _fcm.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    // Création du canal Android (requis Android 8+)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Affichage des notifications FCM en foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _registerToken();
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
    } catch (e) {
      debugPrint('[FCM] erreur enregistrement token: $e');
    }
  }

  // ── Handlers foreground + background (tap sur notif) ─────────────────────

  static void listenForeground(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (!context.mounted) return;
      _handleMessage(context, message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (!context.mounted) return;
      _handleMessage(context, message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      if (!context.mounted) return;
      _handleMessage(context, message.data);
    });
  }

  static void _handleMessage(BuildContext context, Map<String, dynamic> data) {
    final type      = data['type'] as String?;
    final sessionId = data['sessionId'] as String? ?? '';

    switch (type) {
      case 'admin_approval_request':
        _showDialog(context, sessionId, _DialogType.adminLogin);
      case 'admin_vault_auth':
        _showDialog(context, sessionId, _DialogType.vaultAccess);
    }
  }

  static void _showDialog(
      BuildContext context, String sessionId, _DialogType type) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (_) => _ApprovalDialog(sessionId: sessionId, type: type),
    );
  }
}

// ── Type de dialog ────────────────────────────────────────────────────────────

enum _DialogType { adminLogin, vaultAccess }

// ── Widget dialog générique ───────────────────────────────────────────────────

class _ApprovalDialog extends StatefulWidget {
  final String      sessionId;
  final _DialogType type;
  const _ApprovalDialog({required this.sessionId, required this.type});

  @override
  State<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<_ApprovalDialog> {
  bool _loading = false;

  bool get _isVault => widget.type == _DialogType.vaultAccess;

  Future<void> _respond(bool approved) async {
    if (approved) {
      final reason = _isVault
          ? 'Confirmez votre identité pour accéder au vault admin'
          : 'Confirmez votre identité pour approuver la connexion admin';

      final ok = await BiometricService.authenticate(reason: reason);
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
      if (_isVault) {
        await ApiService().respondVaultAuth(token, widget.sessionId, approved);
      } else {
        await ApiService().respondAdminSession(token, widget.sessionId, approved);
      }
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isVault ? Icons.lock_open_rounded : Icons.admin_panel_settings,
            color: _isVault ? Colors.cyanAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 10),
          Text(_isVault ? 'Accès vault admin' : 'Connexion admin'),
        ],
      ),
      content: Text(
        _isVault
            ? 'Une demande d\'accès au vault admin vient d\'être effectuée.\n\n'
              'Approuvez pour déverrouiller le vault.'
            : 'Une tentative de connexion au panneau d\'administration vient d\'être effectuée.\n\n'
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
