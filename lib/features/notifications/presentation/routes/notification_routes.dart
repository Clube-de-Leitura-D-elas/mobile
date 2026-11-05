import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_route_paths.dart';

abstract class NotificationRoutes {
  static const notifications = NotificationRoutePaths.notifications;

  static List<RouteBase> get routes => [
    GoRoute(
      path: notifications,
      pageBuilder: (context, state) => AppPageTransitions.createPushPage(
        state: state,
        child: BlocProvider(
          create: (_) => serviceLocator<NotificationsCubit>()..load(),
          child: const NotificationsPage(),
        ),
      ),
    ),
  ];
}
