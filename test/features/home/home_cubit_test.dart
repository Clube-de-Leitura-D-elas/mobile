import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  group('HomeCubit', () {
    late MockGroupRepository repository;

    const testGroup1 = GroupEntity(
      id: '1',
      number: 1,
      participantsCount: 32,
      cityState: 'Porto Alegre, RS',
    );
    const testGroup27 = GroupEntity(
      id: '27',
      number: 27,
      participantsCount: 18,
      cityState: 'Porto Alegre, RS',
    );

    setUp(() => repository = MockGroupRepository());

    HomeCubit build() => HomeCubit(groupRepository: repository);

    test('starts with an initial state', () {
      final cubit = build();
      addTearDown(cubit.close);

      expect(cubit.state, const HomeState());
    });

    blocTest<HomeCubit, HomeState>(
      'loads the authenticated participant groups from the repository',
      build: () {
        when(
          () => repository.getMyGroups(),
        ).thenAnswer((_) async => const Success([testGroup1, testGroup27]));
        return build();
      },
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.loaded,
          groups: [testGroup1, testGroup27],
        ),
      ],
      verify: (_) => verify(() => repository.getMyGroups()).called(1),
    );

    blocTest<HomeCubit, HomeState>(
      'emits an error when the groups request fails',
      build: () {
        when(
          () => repository.getMyGroups(),
        ).thenAnswer((_) async => const Failure(GroupListFailure()));
        return build();
      },
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.error,
          errorMessage:
              'Não foi possível carregar seus grupos. Tente novamente.',
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'updates the selected filter',
      build: build,
      act: (cubit) => cubit.selectFilter(1),
      expect: () => [const HomeState(selectedFilterIndex: 1)],
    );

    blocTest<HomeCubit, HomeState>(
      'updates the search query',
      build: build,
      act: (cubit) => cubit.updateSearch('Porto Alegre'),
      expect: () => [const HomeState(searchQuery: 'Porto Alegre')],
    );

    blocTest<HomeCubit, HomeState>(
      'recarrega grupos com sucesso ao responder convite de reunião',
      build: () {
        when(
          () => repository.setMeetingInvitationResponse(
            'meeting-1',
            MeetingInvitationStatus.confirmed,
          ),
        ).thenAnswer((_) async => const Success(null));

        when(
          () => repository.getMyGroups(),
        ).thenAnswer((_) async => const Success([testGroup1]));

        return build();
      },
      act: (cubit) => cubit.setMeetingInvitationResponse(
        'meeting-1',
        MeetingInvitationStatus.confirmed,
      ),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.loaded, groups: [testGroup1]),
      ],
      verify: (_) {
        verify(
          () => repository.setMeetingInvitationResponse(
            'meeting-1',
            MeetingInvitationStatus.confirmed,
          ),
        ).called(1);
        verify(() => repository.getMyGroups()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emite erro quando falha ao responder convite de reunião',
      build: () {
        when(
          () => repository.setMeetingInvitationResponse(
            'meeting-1',
            MeetingInvitationStatus.declined,
          ),
        ).thenAnswer(
          (_) async => const Failure(GroupMeetingInvitationResponseFailure()),
        );
        return build();
      },
      act: (cubit) => cubit.setMeetingInvitationResponse(
        'meeting-1',
        MeetingInvitationStatus.declined,
      ),
      expect: () => [
        const HomeState(
          status: HomeStatus.error,
          errorMessage:
              'Não foi possível atualizar sua resposta. Tente novamente.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.setMeetingInvitationResponse(
            'meeting-1',
            MeetingInvitationStatus.declined,
          ),
        ).called(1);
        verifyNever(() => repository.getMyGroups());
      },
    );
  });
}
