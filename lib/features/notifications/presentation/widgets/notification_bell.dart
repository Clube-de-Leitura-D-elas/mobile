import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/app_route_observer.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_route_paths.dart';

/// Sino com o total de não lidas. Atualiza ao voltar de qualquer rota empilhada
/// sobre a tela (inclusive a de notificações) e quando o app volta ao primeiro
/// plano; a carga inicial é feita por quem cria o [NotificationBadgeCubit].
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  static const int maxBadgeCount = 99;

  /// Alvo estável da automação: o rótulo semântico não entra na busca por texto.
  static const buttonKey = ValueKey<String>('notification-bell');

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> with RouteAware {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver
        ..unsubscribe(this)
        ..subscribe(this, route);
    }
  }

  @override
  void didPopNext() => _refresh();

  void _refresh() => context.read<NotificationBadgeCubit>().refresh();

  void _open() {
    context.push<Object?>(NotificationRoutePaths.notifications);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final count = context.watch<NotificationBadgeCubit>().state;

    return Semantics(
      button: true,
      enabled: true,
      label: l10n.notificationsTitle,
      value: count > 0 ? l10n.notificationsUnreadCount(count) : null,
      onTap: _open,
      excludeSemantics: true,
      child: IconButton(
        key: NotificationBell.buttonKey,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        tooltip: l10n.notificationsTitle,
        onPressed: _open,
        icon: Badge(
          isLabelVisible: count > 0,
          backgroundColor: colors.actionPrimary,
          textColor: colors.textOnBrand,
          label: Text(
            count > NotificationBell.maxBadgeCount
                ? l10n.notificationsBadgeOverflow
                : '$count',
          ),
          child: AppIcon(
            icon: AppIcons.bell,
            size: 24,
            color: colors.textDefault,
          ),
        ),
      ),
    );
  }
}
