import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_route_paths.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:mobile/features/notifications/presentation/widgets/notifications_message_view.dart';
import 'package:mobile/features/notifications/presentation/widgets/notifications_skeleton.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      appBar: ScreenHeader.back(title: context.l10n.notificationsTitle),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final cubit = context.read<NotificationsCubit>();

          return switch (state.status) {
            NotificationsStatus.loading => const NotificationsSkeleton(),
            NotificationsStatus.error => NotificationsMessageView(
              message: switch (state.failure) {
                NotificationNetworkFailure() => l10n.errorNoConnection,
                NotificationSessionExpiredFailure() => l10n.errorSessionExpired,
                _ => l10n.notificationsLoadError,
              },
              onRetry: cubit.load,
              secondaryLabel: state.failure is NotificationSessionExpiredFailure
                  ? l10n.logoutTooltip
                  : null,
              onSecondary: () => context.read<SessionCubit>().logOut(),
            ),
            NotificationsStatus.loaded when state.items.isEmpty =>
              NotificationsMessageView(message: l10n.notificationsEmpty),
            NotificationsStatus.loaded => _NotificationsList(state: state),
          };
        },
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final NotificationsState state;

  const _NotificationsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cubit = context.read<NotificationsCubit>();
    final items = state.items;
    // O padding explícito desliga o recuo automático da área segura.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView.separated(
      padding: EdgeInsets.all(
        spacing.s16,
      ).copyWith(bottom: spacing.s16 + bottomInset),
      itemCount: items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: spacing.s12),
      itemBuilder: (context, index) {
        if (index < items.length) {
          final notification = items[index];
          return NotificationTile(
            key: ValueKey(notification.id),
            notification: notification,
            onTap: () => _open(context, notification),
          );
        }
        if (state.loadMoreFailed) {
          return NotificationsMessageView(
            message: context.l10n.notificationsLoadMoreError,
            onRetry: cubit.loadMore,
          );
        }
        return _LoadMoreTrigger(
          key: ValueKey(state.page),
          onVisible: cubit.loadMore,
        );
      },
    );
  }

  void _open(BuildContext context, NotificationEntity notification) {
    unawaited(context.read<NotificationsCubit>().markAsRead(notification));

    final destination = NotificationRoutePaths.destinationFor(notification);
    if (destination != null) {
      unawaited(context.push<Object?>(destination));
    }
  }
}

/// Fim da lista: o ListView só constrói este item quando ele se aproxima da
/// tela, o que também cobre a primeira página que não preenche a tela toda.
class _LoadMoreTrigger extends StatefulWidget {
  final VoidCallback onVisible;

  const _LoadMoreTrigger({super.key, required this.onVisible});

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.l10n.notificationsLoadingMore,
        child: CircularProgressIndicator(color: context.colors.actionPrimary),
      ),
    );
  }
}
