import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @visibleForTesting
  static String? pendingRoute;

  /// Extrai a rota alvo a partir do mapa `data` do FCM.
  static String? parseRouteFromData(Map<String, dynamic> data) {
    // 1. Rota explícita enviada no payload (ex: "/group-details?group_id=123")
    final route = data['route'] as String?;
    if (route != null && route.trim().isNotEmpty) {
      return route.trim();
    }

    // 2. Extração inteligente por screen e IDs
    final screen = data['screen'] as String?;
    final groupId = data['group_id'] as String?;
    final meetingId = data['meeting_id'] as String?;

    if (screen == '/group-details' ||
        screen == 'group-details' ||
        (groupId != null && meetingId == null)) {
      if (groupId != null && groupId.trim().isNotEmpty) {
        return '/group-details?group_id=${groupId.trim()}';
      }
    }

    if (screen == '/meeting-details' ||
        screen == 'meeting-details' ||
        meetingId != null) {
      if (meetingId != null && meetingId.trim().isNotEmpty) {
        return '/meeting-details?meeting_id=${meetingId.trim()}';
      }
    }

    if (screen != null && screen.trim().startsWith('/')) {
      return screen.trim();
    }

    return null;
  }

  /// Trata o clique na notificação (seja em cold start ou em background).
  static void handleNotificationClick(
    Map<String, dynamic> data, {
    bool isColdStart = false,
  }) {
    final route = parseRouteFromData(data);
    if (route == null) return;

    if (isColdStart) {
      pendingRoute = route;
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).push(route);
      } else {
        pendingRoute = route;
      }
    }
  }

  /// Consome a rota pendente (se houver) para navegação inicial pós-splash.
  static String? consumePendingRoute() {
    final route = pendingRoute;
    pendingRoute = null;
    return route;
  }
}
