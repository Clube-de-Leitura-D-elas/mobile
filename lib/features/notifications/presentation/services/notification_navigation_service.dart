import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @visibleForTesting
  static String? pendingRoute;

  static StreamSubscription<Map<String, dynamic>>? _openedSubscription;

  /// Configura os listeners de clique em notificações (cold start e background).
  static Future<void> setupInteractions(
    NotificationRepository repository,
  ) async {
    await _openedSubscription?.cancel();
    _openedSubscription = repository.onNotificationOpened.listen((data) {
      _markAsReadIfPresent(repository, data);
      handleNotificationClick(data, isColdStart: false);
    });

    try {
      final initialData = await repository.getInitialNotificationData();
      if (initialData != null && initialData.isNotEmpty) {
        _markAsReadIfPresent(repository, initialData);
        handleNotificationClick(initialData, isColdStart: true);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationNavigationService] Error reading initial notification: $e\n$stackTrace',
        );
      }
    }
  }

  static void _markAsReadIfPresent(
    NotificationRepository repository,
    Map<String, dynamic> data,
  ) {
    final notificationId = (data['notification_id'] ?? data['id'])
        ?.toString()
        .trim();
    if (notificationId != null && notificationId.isNotEmpty) {
      unawaited(repository.markAsRead(notificationId));
    }
  }

  /// Extrai a rota alvo a partir do mapa `data` do FCM.
  static String? parseRouteFromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && route.trim().isNotEmpty) {
      return route.trim();
    }

    final screen = data['screen'] as String?;
    final groupId = data['group_id'] as String?;
    final meetingId = data['meeting_id'] as String?;

    // Vêm com `meeting_id`, mas a convidada não abre o detalhe de membro.
    if (data['type'] == 'MEETING_GUEST_APPROVED' ||
        data['type'] == 'MEETING_GUEST_REJECTED') {
      return QuickAccessRoutes.calendar;
    }

    if (screen == GroupRoutePaths.meetingDetails ||
        screen == '/meeting-details' ||
        screen == 'meeting-details' ||
        meetingId != null) {
      if (meetingId != null && meetingId.trim().isNotEmpty) {
        return Uri(
          path: GroupRoutePaths.meetingDetails,
          queryParameters: {'meeting_id': meetingId.trim()},
        ).toString();
      }
    }

    // Recusada (ou aprovada e depois fora do grupo), o detalhe de membro
    // recusaria; a tela pública mostra o vínculo atual.
    if ((data['type'] == 'GROUP_JOIN_REJECTED' ||
            data['type'] == 'GROUP_JOIN_APPROVED') &&
        groupId != null &&
        groupId.trim().isNotEmpty) {
      return GroupDiscoveryRoutePaths.publicGroupFor(groupId.trim());
    }

    if (data['type'] == 'GROUP_JOIN_REQUESTED' &&
        groupId != null &&
        groupId.trim().isNotEmpty) {
      return GroupJoinRequestsRoutePaths.joinRequestsFor(groupId.trim());
    }

    if (screen == GroupRoutePaths.groupDetails ||
        screen == 'group-details' ||
        (groupId != null && meetingId == null)) {
      if (groupId != null && groupId.trim().isNotEmpty) {
        return Uri(
          path: GroupRoutePaths.groupDetails,
          queryParameters: {'group_id': groupId.trim()},
        ).toString();
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
