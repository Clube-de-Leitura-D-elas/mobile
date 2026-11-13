import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GroupRepository groupRepository;

  HomeCubit({required this.groupRepository}) : super(const HomeState());

  // Só a leitura mais recente vale: um load e um refresh podem se cruzar.
  int _latestRead = 0;

  Future<void> loadGroups() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final read = ++_latestRead;
    final result = await groupRepository.getMyGroups();
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Failure(:final failure):
        emit(state.copyWith(status: HomeStatus.error, error: failure));
      case Success(:final data):
        final expandedGroupIds = data
            .where((group) => group.nextMeeting != null)
            .map((group) => group.id)
            .toSet();
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            groups: data,
            expandedGroupIds: expandedGroupIds,
          ),
        );
    }
  }

  /// Atualiza os grupos sem passar pelo carregamento (ex.: ao voltar de outra
  /// tela, onde a leitora pode ter entrado num grupo ou aprovado alguém); se
  /// falhar, fica o que já está na tela.
  Future<void> refreshGroups() async {
    if (state.status != HomeStatus.loaded) return;
    final read = ++_latestRead;
    final result = await groupRepository.getMyGroups();
    if (isClosed || read != _latestRead) return;

    if (result case Success(:final data)) {
      final knownIds = state.groups.map((group) => group.id).toSet();
      final currentIds = data.map((group) => group.id).toSet();
      emit(
        state.copyWith(
          groups: data,
          expandedGroupIds: {
            ...state.expandedGroupIds.where(currentIds.contains),
            ...data
                .where(
                  (group) =>
                      !knownIds.contains(group.id) && group.nextMeeting != null,
                )
                .map((group) => group.id),
          },
        ),
      );
    }
  }

  void toggleCardExpansion(String groupId) {
    final currentExpanded = Set<String>.from(state.expandedGroupIds);
    if (currentExpanded.contains(groupId)) {
      currentExpanded.remove(groupId);
    } else {
      currentExpanded.add(groupId);
    }
    emit(state.copyWith(expandedGroupIds: currentExpanded));
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
