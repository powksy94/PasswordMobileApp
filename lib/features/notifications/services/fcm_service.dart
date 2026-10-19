import 'dart:ui' as ui;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../shared/services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../../home/services/home_tab_request_service.dart';
import '../widgets/approval_dialog.dart';

/// Handles Firebase Cloud Messaging:
/// - FCM token registration
/// - Admin approval notifications (dashboard login)
/// - Vault admin approval notifications (vault access)
/// - Weak/medium item push reminders
class FcmService {
  static final _fcm = FirebaseMessaging.instance;

  static const _channelId   = 'admin_auth';
  static const _channelName = 'Approbations admin';

  static const _weakReminderChannelId   = 'weak_reminders';
  static const _weakReminderChannelName = 'Rappels de sécurité';

  // Locales actually supported by the app (see supportedLocales in
  // main.dart) - sent alongside the FCM token so server-sent push text
  // (weak_item_reminder) can match the app's own localization.
  static const _supportedLocales = {'en', 'fr', 'es'};

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // ── Initialization ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    await _fcm.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    // Android channel creation (required on Android 8+)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    const weakReminderChannel = AndroidNotificationChannel(
      _weakReminderChannelId,
      _weakReminderChannelName,
      importance: Importance.defaultImportance,
    );
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.createNotificationChannel(weakReminderChannel);

    // Display FCM notifications in the foreground
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
      await ApiService().registerFcmToken(authToken, token, locale: _currentLocale());
    } catch (e) {
      debugPrint('[FCM] token registration error: $e');
    }
  }

  /// Device locale restricted to the app's actually supported ones
  /// (fallback 'en', the app's default - see supportedLocales in main.dart).
  static String _currentLocale() {
    final code = ui.PlatformDispatcher.instance.locale.languageCode;
    return _supportedLocales.contains(code) ? code : 'en';
  }

  // ── Handlers foreground + background (notification tap) ─────────────────────

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
    final requestIp = data['requestIp'] as String?;

    switch (type) {
      case 'admin_approval_request':
        final targetUserId = data['userId'] as String?;
        if (targetUserId != null) {
          final myId = await AuthService.getUserId();
          if (myId != targetUserId) return;
        }
        if (context.mounted) {
          _showDialog(context, sessionId, ApprovalDialogType.adminLogin, requestIp);
        }
      case 'admin_vault_auth':
        if (context.mounted) {
          _showDialog(context, sessionId, ApprovalDialogType.vaultAccess, requestIp);
        }
      case 'weak_item_reminder':
        // Informational only (unlike the admin approval cases above): no
        // confirmation dialog, just switch HomePage to the Health tab.
        HomeTabRequestService.requestHealthTab();
    }
  }

  static void _showDialog(BuildContext context, String sessionId,
      ApprovalDialogType type, String? requestIp) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (_) => ApprovalDialog(sessionId: sessionId, type: type, requestIp: requestIp),
    );
  }
}
