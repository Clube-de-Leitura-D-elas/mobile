import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_state.dart';

class GroupParticipantsCubit extends Cubit<GroupParticipantsState> {
  final GroupParticipantsRepository participantsRepository;
  String? _groupId;
  // Só a leitura mais recente vale: um load lento não sobrescreve o refresh.
  int _latestRead = 0;

  GroupParticipantsCubit({required this.participantsRepository})
    : super(const GroupParticipantsLoading());

  Future<void> load(String groupId) async {
    _groupId = groupId;
    emit(const GroupParticipantsLoading());

    final read = ++_latestRead;
    final result = await participantsRepository.getParticipants(groupId);
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Failure(:final failure):
        emit(GroupParticipantsError(failure.message));
      case Success(:final data):
        emit(
          data.isEmpty
              ? const GroupParticipantsEmpty()
              : GroupParticipantsLoaded(data),
        );
    }
  }

  Future<void> retry() async {
    final groupId = _groupId;
    if (groupId == null) return;
    await load(groupId);
  }

  /// Atualiza a lista sem passar pelo carregamento; se falhar, fica o que já
  /// está na tela. Se ainda não havia lista (o load inicial foi invalidado por
  /// este refresh), a falha vira erro para a tela não ficar presa carregando.
  Future<void> refresh() async {
    final groupId = _groupId;
    if (groupId == null) return;
    final read = ++_latestRead;
    final result = await participantsRepository.getParticipants(groupId);
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Success(:final data):
        emit(
          data.isEmpty
              ? const GroupParticipantsEmpty()
              : GroupParticipantsLoaded(data),
        );
      case Failure(:final failure) when state is GroupParticipantsLoading:
        emit(GroupParticipantsError(failure.message));
      case Failure():
        return;
    }
  }
}
