import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../shared/services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/approval_dialog.dart';

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

  static Future<void> _handleMessage(BuildContext context, Map<String, dynamic> data) async {
    final type      = data['type'] as String?;
    final sessionId = data['sessionId'] as String? ?? '';

    switch (type) {
      case 'admin_approval_request':
        final targetUserId = data['userId'] as String?;
        if (targetUserId != null) {
          final myId = await AuthService.getUserId();
          if (myId != targetUserId) return;
        }
        if (context.mounted) _showDialog(context, sessionId, ApprovalDialogType.adminLogin);
      case 'admin_vault_auth':
        if (context.mounted) _showDialog(context, sessionId, ApprovalDialogType.vaultAccess);
    }
  }

  static void _showDialog(
      BuildContext context, String sessionId, ApprovalDialogType type) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (_) => ApprovalDialog(sessionId: sessionId, type: type),
    );
  }
}
