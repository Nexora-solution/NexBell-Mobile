import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../utils/api_client.dart';
import '../../features/attend/presentation/pages/attend_page.dart';

/// Must be a top-level (or static) function — required by firebase_messaging
/// to run in its own isolate when the app is fully terminated and a push
/// notification arrives. The system tray already displays the notification
/// from the payload's `notification` block, so there is nothing else to do
/// here; navigation happens once the user taps it and the app resumes.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Wires Firebase Cloud Messaging end to end: requests permission, registers
/// this device's token with the backend, and navigates straight to
/// [AttendVisitPage] whenever a "new visit" notification arrives — whether
/// the app is in the foreground, background, or was fully closed.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;
    _initialized = true;
    _navigatorKey = navigatorKey;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // App fully closed, opened directly by tapping the notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleVisitNotification(initialMessage);
    }

    // App in background, brought to foreground by tapping the notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleVisitNotification);

    // App already open in the foreground when the notification arrives.
    FirebaseMessaging.onMessage.listen(_handleVisitNotification);
  }

  /// Call after a successful login to register/refresh this device's FCM
  /// token with the backend so it can actually receive push notifications.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await ApiClient.post('/api/iam/users/me/fcm-token', body: {'fcmToken': token});
    } catch (_) {
      // Non-fatal — the resident simply won't get push notifications this session.
    }
  }

  void _handleVisitNotification(RemoteMessage message) {
    final id = int.tryParse(message.data['id'] ?? '');
    if (id == null) return;
    // "VISIT_REQUEST" (ad-hoc walk-in flow) or "PRE_REGISTERED_VISIT" (the
    // resident's own pre-registered visitor) — tells AttendVisitPage which
    // set of backend endpoints to call for this id.
    final visitType = message.data['type'] ?? 'VISIT_REQUEST';

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    navigator.push(MaterialPageRoute(
      builder: (_) => AttendVisitPage(visitId: id, visitType: visitType),
    ));
  }
}
