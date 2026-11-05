import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_relative_date.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_type_icon.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  static const double _iconSize = 20;
  static const double _unreadDotSize = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final isUnread = !notification.isRead;
    final title = notification.title;
    final message = notification.message;
    final date = formatNotificationDate(
      l10n,
      date: notification.date,
      now: DateTime.now(),
    );
    final titleStyle = isUnread
        ? typography.bodyDefaultEmphasis
        : typography.bodyDefault;
    final supportStyle = typography.bodySmall.copyWith(color: colors.textMuted);

    return Semantics(
      button: true,
      enabled: true,
      label: isUnread
          ? l10n.notificationTileUnreadSemantic(title, message)
          : l10n.notificationTileReadSemantic(title, message),
      value: date,
      onTap: onTap,
      excludeSemantics: true,
      child: AppCard(
        // A borda do AppCard alterna a cada toque e inverteria a marcação de
        // não lida; o destaque fica no ponto, no ícone e no título.
        showBorder: false,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(
              icon: notificationIconFor(notification.type),
              size: _iconSize,
              color: isUnread ? colors.textBrand : colors.textMuted,
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: titleStyle.copyWith(color: colors.textDefault),
                  ),
                  SizedBox(height: spacing.s4),
                  Text(message, style: supportStyle),
                  SizedBox(height: spacing.s4),
                  Text(date, style: supportStyle),
                ],
              ),
            ),
            if (isUnread) ...[
              SizedBox(width: spacing.s8),
              Container(
                key: const Key('notification-unread-dot'),
                width: _unreadDotSize,
                height: _unreadDotSize,
                decoration: BoxDecoration(
                  color: colors.actionPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
