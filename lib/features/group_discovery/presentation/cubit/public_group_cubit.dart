import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/uuid.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_state.dart';

class PublicGroupCubit extends Cubit<PublicGroupState> {
  final GroupDiscoveryRepository repository;
  String _groupId = '';

  PublicGroupCubit({required this.repository})
    : super(const PublicGroupState());

  Future<void> load(String groupId) async {
    _groupId = groupId;
    // Link sem `group_id` ou com id inválido: o backend recusaria igual.
    if (!isUuid(groupId)) {
      emit(const PublicGroupState(status: PublicGroupStatus.unavailable));
      return;
    }
    emit(const PublicGroupState());

    final result = await repository.getGroup(groupId);
    if (isClosed) return;

    switch (result) {
      case Failure(failure: GroupUnavailableFailure()):
        emit(const PublicGroupState(status: PublicGroupStatus.unavailable));
      case Failure(:final failure):
        emit(
          PublicGroupState(status: PublicGroupStatus.error, failure: failure),
        );
      case Success(:final data):
        emit(PublicGroupState(status: PublicGroupStatus.loaded, group: data));
    }
  }

  Future<void> retry() => load(_groupId);

  Future<void> requestJoin() async {
    final group = state.group;
    if (isClosed) return;
    if (group == null || !group.canRequestJoin || state.isRequesting) return;

    emit(
      state.copyWith(
        isRequesting: true,
        joinRequested: false,
        clearJoinFailure: true,
      ),
    );

    final result = await repository.requestJoin(group.id);
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(
          state.copyWith(
            group: group.copyWith(
              membershipStatus: GroupMembershipStatus.requested,
            ),
            isRequesting: false,
            joinRequested: true,
          ),
        );
      case Failure(failure: GroupUnavailableFailure()):
        emit(const PublicGroupState(status: PublicGroupStatus.unavailable));
      case Failure(:final failure)
          when failure is GroupJoinAlreadyRequestedFailure:
        // O botão segue ocupado até o status real chegar.
        emit(state.copyWith(joinFailure: failure));
        await _refreshGroup(group.id);
      case Failure(:final failure):
        emit(state.copyWith(isRequesting: false, joinFailure: failure));
    }
  }

  void clearJoinFeedback() {
    emit(state.copyWith(joinRequested: false, clearJoinFailure: true));
  }

  /// Atualiza o status do grupo sem trocar a tela por carregamento; se falhar,
  /// fica o que já está na tela.
  Future<void> _refreshGroup(String groupId) async {
    final result = await repository.getGroup(groupId);
    if (isClosed) return;

    emit(
      state.copyWith(
        group: result is Success<DiscoveryGroupEntity, GroupDiscoveryFailure>
            ? result.data
            : null,
        isRequesting: false,
      ),
    );
  }
}
