import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

/// Quantidade de notificações não lidas exibida no sino.
class NotificationBadgeCubit extends Cubit<int> {
  final NotificationRepository repository;

  int _nextRefreshId = 0;
  int _lastAppliedRefreshId = 0;

  NotificationBadgeCubit({required this.repository}) : super(0);

  Future<void> refresh() async {
    final refreshId = ++_nextRefreshId;
    final result = await repository.getNotifications(page: 1);
    if (isClosed) return;

    // O badge é secundário: em falha mantém o último valor até a próxima
    // atualização, em vez de esconder o aviso de não lidas.
    if (result case Success(:final data)) {
      // Respostas podem chegar fora de ordem quando os refreshes se sobrepõem.
      if (refreshId < _lastAppliedRefreshId) return;
      _lastAppliedRefreshId = refreshId;
      emit(data.unreadCount);
    }
  }
}
