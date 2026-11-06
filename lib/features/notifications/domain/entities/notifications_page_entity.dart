import 'package:equatable/equatable.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';

class NotificationsPageEntity extends Equatable {
  final List<NotificationEntity> items;
  final int total;
  final int unreadCount;

  const NotificationsPageEntity({
    required this.items,
    required this.total,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [items, total, unreadCount];
}
