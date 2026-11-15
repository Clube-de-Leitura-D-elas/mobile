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
  /// falhar, fica o que já está na tela (o load e o sino tratam sessão expirada).
  Future<void> refreshGroups() async {
    // Com erro na tela, voltar tenta de novo (como o load fazia antes).
    if (state.status == HomeStatus.error) return loadGroups();
    // Durante um load, esta leitura o substitui: a dele pode ser de antes da
    // mudança feita na outra tela.
    if (state.status != HomeStatus.loaded &&
        state.status != HomeStatus.loading) {
      return;
    }
    final read = ++_latestRead;
    final result = await groupRepository.getMyGroups();
    if (isClosed || read != _latestRead) return;

    if (result case Failure(
      :final failure,
    ) when state.status == HomeStatus.loading) {
      emit(state.copyWith(status: HomeStatus.error, error: failure));
      return;
    }
    if (result case Success(:final data)) {
      final previousMeetingIds = {
        for (final group in state.groups) group.id: group.nextMeeting?.id,
      };
      final currentIds = data.map((group) => group.id).toSet();
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          groups: data,
          expandedGroupIds: {
            ...state.expandedGroupIds.where(currentIds.contains),
            // Grupo novo ou com encontro novo abre expandido, como no load.
            ...data
                .where(
                  (group) =>
                      group.nextMeeting != null &&
                      (!previousMeetingIds.containsKey(group.id) ||
                          previousMeetingIds[group.id] !=
                              group.nextMeeting!.id),
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
