import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_state.dart';

class GroupParticipantsCubit extends Cubit<GroupParticipantsState> {
  final GroupParticipantsRepository participantsRepository;
  String? _groupId;

  GroupParticipantsCubit({required this.participantsRepository})
    : super(const GroupParticipantsLoading());

  Future<void> load(String groupId) async {
    _groupId = groupId;
    emit(const GroupParticipantsLoading());

    final result = await participantsRepository.getParticipants(groupId);
    if (isClosed) return;

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
}
