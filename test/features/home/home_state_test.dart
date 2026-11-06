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

GroupMeeting _pendingMeeting(String id, {int tasksDone = 0}) {
  return GroupMeeting(
    id: id,
    hostName: 'Ana',
    bookTitle: 'Livro',
    date: '',
    location: '',
    canManageTasks: true,
    tasksDone: tasksDone,
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
      'Given dois encontros pendentes no mesmo grupo, Then uma entrada por encontro',
      () {
        final draft = _pendingMeeting('m-draft');
        final ended = _pendingMeeting('m-ended', tasksDone: 1);
        final coordinator = _group(
          5,
          withMeeting: false,
        ).copyWith(pendingMeetings: [ended, draft]);
        final state = HomeState(groups: [first, coordinator]);

        expect(state.pendingTasksGroups.map((group) => group.nextMeeting?.id), [
          'm-ended',
          'm-draft',
        ]);
        expect(state.pendingTasksGroups.map((group) => group.id), ['g5', 'g5']);
        expect(state.hasPendingTasks, isTrue);
      },
    );

    test(
      'Given next_meeting com tarefas e pending_meetings vazio, Then ainda aparece',
      () {
        final host = _group(4, canManageTasks: true, tasksDone: 1);
        final state = HomeState(groups: [host]);

        expect(state.pendingTasksGroups.single.nextMeeting?.id, 'm4');
      },
    );

    test(
      'Given next_meeting repetido em pending_meetings, Then aparece uma vez',
      () {
        final host = _group(4, canManageTasks: true, tasksDone: 1);
        final withPending = host.copyWith(
          pendingMeetings: [host.nextMeeting!, _pendingMeeting('m-draft')],
        );
        final state = HomeState(groups: [withPending]);

        expect(state.pendingTasksGroups.map((group) => group.nextMeeting?.id), [
          'm4',
          'm-draft',
        ]);
      },
    );

    test(
      'Given o mesmo encontro duas vezes em pending_meetings, Then aparece uma vez',
      () {
        final draft = _pendingMeeting('m-draft');
        final group = _group(
          7,
          withMeeting: false,
        ).copyWith(pendingMeetings: [draft, draft]);

        expect(HomeState(groups: [group]).pendingTasksGroups, hasLength(1));
      },
    );

    test('Given pendente sem permissão ou já concluído, Then fica de fora', () {
      final done = _pendingMeeting('m-done', tasksDone: 2);
      const notManager = GroupMeeting(
        id: 'm-other',
        hostName: 'Ana',
        bookTitle: 'Livro',
        date: '',
        location: '',
      );
      final group = _group(
        6,
        withMeeting: false,
      ).copyWith(pendingMeetings: [done, notManager]);

      expect(HomeState(groups: [group]).pendingTasksGroups, isEmpty);
    });
  });
}
