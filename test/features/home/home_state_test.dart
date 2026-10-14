import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';

GroupEntity _group(
  int number, {
  bool withMeeting = true,
  bool pending = false,
}) {
  return GroupEntity(
    id: 'g$number',
    number: number,
    participantsCount: 10,
    cityState: 'Porto Alegre, RS',
    hasPendingResponse: pending,
    nextMeeting: withMeeting
        ? const GroupMeeting(
            id: 'm',
            hostName: 'Ana',
            bookTitle: 'Livro',
            date: '10/10',
            location: 'Casa da Ana',
          )
        : null,
  );
}

String _nameOf(GroupEntity g) => 'Grupo ${g.number}';

void main() {
  final pending = _group(1, pending: true);
  final answered = _group(2);
  final noMeeting = _group(3, withMeeting: false);
  final base = HomeState(groups: [pending, answered, noMeeting]);

  test(
    'Given filtro "Respondidos", When filtra, Then exclui grupo sem encontro',
    () {
      final state = base.copyWith(filter: HomeFilter.answered);

      expect(state.filteredGroups(_nameOf), [answered]);
    },
  );

  test(
    'Given filtro "Não respondidos" e busca, When filtra, Then combina os dois',
    () {
      final state = base.copyWith(
        filter: HomeFilter.unanswered,
        searchQuery: ' grupo 1 ',
      );

      expect(state.filteredGroups(_nameOf), [pending]);
    },
  );

  test('Given contagem, When busca muda, Then unansweredCount não muda', () {
    final state = base.copyWith(searchQuery: 'xyz');

    expect(state.unansweredCount, 1);
  });

  test('Given filtro com itens e busca sem match, Then noSearchResults', () {
    final state = base.copyWith(searchQuery: 'xyz');

    expect(
      state.emptyKindFor(state.filteredGroups(_nameOf)),
      HomeEmptyKind.noSearchResults,
    );
  });

  test(
    'Given ninguém pendente, When filtro "Não respondidos", Then noUnanswered',
    () {
      final state = HomeState(
        groups: [answered],
        filter: HomeFilter.unanswered,
      );

      expect(
        state.emptyKindFor(state.filteredGroups(_nameOf)),
        HomeEmptyKind.noUnanswered,
      );
    },
  );
}
