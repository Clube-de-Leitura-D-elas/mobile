import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';

GroupEntity _group(
  int number, {
  bool withMeeting = true,
  bool canManageTasks = false,
  int tasksDone = 0,
}) {
  return GroupEntity(
    id: 'g$number',
    number: number,
    participantsCount: 10,
    cityState: 'Porto Alegre, RS',
    nextMeeting: withMeeting
        ? GroupMeeting(
            id: 'm$number',
            hostName: 'Ana',
            bookTitle: 'Livro',
            date: '10/10',
            location: 'Casa da Ana',
            canManageTasks: canManageTasks,
            tasksDone: tasksDone,
          )
        : null,
  );
}

String _nameOf(GroupEntity g) => 'Grupo ${g.number}';

void main() {
  final first = _group(1);
  final second = _group(2);
  final noMeeting = _group(3, withMeeting: false);
  final base = HomeState(groups: [first, second, noMeeting]);

  test('Given busca vazia, When filtra, Then retorna todos os grupos', () {
    expect(base.filteredGroups(_nameOf), [first, second, noMeeting]);
  });

  test(
    'Given busca com espaços, When filtra, Then aplica trim e ignora caixa',
    () {
      final state = base.copyWith(searchQuery: ' GRUPO 1 ');

      expect(state.filteredGroups(_nameOf), [first]);
    },
  );

  test('Given grupos e busca sem match, Then noSearchResults', () {
    final state = base.copyWith(searchQuery: 'xyz');

    expect(
      state.emptyKindFor(state.filteredGroups(_nameOf)),
      HomeEmptyKind.noSearchResults,
    );
  });

  test('Given nenhum grupo, Then noGroups', () {
    const state = HomeState();

    expect(
      state.emptyKindFor(state.filteredGroups(_nameOf)),
      HomeEmptyKind.noGroups,
    );
  });

  group('pendingTasksGroups', () {
    test('Given não é anfitriã, Then não há tarefas pendentes', () {
      expect(base.pendingTasksGroups, isEmpty);
      expect(base.hasPendingTasks, isFalse);
    });

    test(
      'Given anfitriã com tarefas pendentes, Then retorna só esse grupo',
      () {
        final host = _group(4, canManageTasks: true, tasksDone: 1);
        final state = HomeState(groups: [first, host]);

        expect(state.pendingTasksGroups, [host]);
        expect(state.hasPendingTasks, isTrue);
      },
    );

    test(
      'Given anfitriã com todas as tarefas concluídas, Then lista vazia',
      () {
        final host = _group(4, canManageTasks: true, tasksDone: 2);
        final state = HomeState(groups: [host]);

        expect(state.pendingTasksGroups, isEmpty);
      },
    );

    test(
      'Given coordenadora com dois encontros pendentes no mesmo grupo (ENDED e CREATED), Then retorna um item para cada encontro',
      () {
        const endedMeeting = GroupMeeting(
          id: 'm-ended',
          hostName: 'Gabriela',
          bookTitle: 'O Avesso da Pele',
          date: '02/11',
          location: 'PUCRS',
          canManageTasks: true,
          tasksDone: 1,
        );
        const createdMeeting = GroupMeeting(
          id: 'm-created',
          hostName: 'Patrícia',
          bookTitle: 'Quarto de Despejo',
          date: '',
          location: '',
          canManageTasks: true,
          tasksDone: 0,
        );
        const group = GroupEntity(
          id: 'g2',
          number: 2,
          participantsCount: 5,
          cityState: 'Porto Alegre, RS',
          nextMeeting: endedMeeting,
          pendingMeetings: [endedMeeting, createdMeeting],
        );

        const state = HomeState(groups: [group]);

        expect(state.pendingTasksGroups, hasLength(2));
        expect(state.pendingTasksGroups[0].nextMeeting, endedMeeting);
        expect(state.pendingTasksGroups[1].nextMeeting, createdMeeting);
      },
    );
  });
}
