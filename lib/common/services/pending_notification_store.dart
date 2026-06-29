import 'package:flutter/foundation.dart';

/// The most recent unresolved "visit at the door" push notification. Set when
/// a push arrives (see [PushNotificationService]); read by the bell badge and
/// the Notifications screen so a resident who missed the live push can still
/// find it and tap into the same live-video [AttendVisitPage] flow. Cleared
/// once a decision is made or the resident dismisses it.
class PendingVisitNotification {
  final int visitId;
  final String visitType;
  final String? visitorName;
  final DateTime receivedAt;

  PendingVisitNotification({
    required this.visitId,
    required this.visitType,
    this.visitorName,
    required this.receivedAt,
  });
}

class PendingNotificationStore {
  PendingNotificationStore._();

  static final ValueNotifier<PendingVisitNotification?> current =
      ValueNotifier<PendingVisitNotification?>(null);

  static void set(PendingVisitNotification notification) {
    current.value = notification;
  }

  static void clear() {
    current.value = null;
  }
}
