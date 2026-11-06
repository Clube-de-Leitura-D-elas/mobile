import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;

  NotificationsCubit({required this.repository})
    : super(const NotificationsState());

  Future<void> load() async {
    emit(const NotificationsState());

    final result = await repository.getNotifications(page: 1);
    if (isClosed) return;

    switch (result) {
      case Failure():
        emit(const NotificationsState(status: NotificationsStatus.error));
      case Success(:final data):
        emit(
          NotificationsState(
            status: NotificationsStatus.loaded,
            items: data.items,
            total: data.total,
            page: 1,
          ),
        );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));

    final nextPage = state.page + 1;
    final result = await repository.getNotifications(page: nextPage);
    if (isClosed) return;

    switch (result) {
      case Failure():
        emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
      case Success(:final data):
        // Notificação nova desloca as páginas e pode repetir item já carregado.
        final loadedIds = state.items.map((item) => item.id).toSet();
        emit(
          state.copyWith(
            items: [
              ...state.items,
              ...data.items.where((item) => !loadedIds.contains(item.id)),
            ],
            total: data.total,
            page: nextPage,
            isLoadingMore: false,
          ),
        );
    }
  }

  /// Marca como lida na tela antes da resposta e desfaz se o backend recusar.
  Future<void> markAsRead(NotificationEntity notification) async {
    if (notification.isRead) return;
    _setRead(notification.id, isRead: true);

    final result = await repository.markAsRead(notification.id);
    if (isClosed) return;

    if (result is Failure) _setRead(notification.id, isRead: false);
  }

  void _setRead(String id, {required bool isRead}) {
    emit(
      state.copyWith(
        items: [
          for (final item in state.items)
            item.id == id ? item.copyWith(isRead: isRead) : item,
        ],
      ),
    );
  }
}
