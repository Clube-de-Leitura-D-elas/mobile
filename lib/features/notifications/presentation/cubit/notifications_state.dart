import 'package:equatable/equatable.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

enum NotificationsStatus { loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> items;
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  bool get hasMore => page * NotificationRepository.pageSize < total;

  NotificationsState copyWith({
    List<NotificationEntity>? items,
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return NotificationsState(
      status: status,
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    total,
    page,
    isLoadingMore,
    loadMoreFailed,
  ];
}
