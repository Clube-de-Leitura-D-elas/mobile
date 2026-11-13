import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  final GroupRepository groupRepository;

  GroupDetailsCubit({required this.groupRepository})
    : super(const GroupDetailsLoading());

  String _groupId = '';

  Future<void> retry() => load(_groupId);

  Future<void> load(String groupId) async {
    _groupId = groupId;
    emit(const GroupDetailsLoading());

    final result = await groupRepository.getGroupDetails(groupId);

    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(GroupDetailsLoaded(data));
      case Failure(:final failure):
        emit(GroupDetailsError(failure));
    }
  }

  /// Atualiza os dados sem trocar a tela por carregamento; se falhar, fica o
  /// que já está na tela.
  Future<void> refresh() async {
    if (state is! GroupDetailsLoaded) return;
    final result = await groupRepository.getGroupDetails(_groupId);
    if (isClosed) return;

    if (result case Success(:final data)) emit(GroupDetailsLoaded(data));
  }
}
