import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_discovery_fixtures.dart';

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

void main() {
  late MockGroupDiscoveryRepository repository;

  final noneGroup = discoveryGroup();
  final loaded = PublicGroupState(
    status: PublicGroupStatus.loaded,
    group: noneGroup,
  );

  setUp(() {
    repository = MockGroupDiscoveryRepository();
  });

  PublicGroupCubit buildCubit() => PublicGroupCubit(repository: repository);

  group('load', () {
    blocTest<PublicGroupCubit, PublicGroupState>(
      'emits the group',
      setUp: () => when(
        () => repository.getGroup(groupId),
      ).thenAnswer((_) async => Success(noneGroup)),
      build: buildCubit,
      act: (cubit) => cubit.load(groupId),
      expect: () => [const PublicGroupState(), loaded],
    );

    for (final invalidId in ['', 'abc', '$groupId-x']) {
      blocTest<PublicGroupCubit, PublicGroupState>(
        'is unavailable without asking the backend for the id "$invalidId"',
        build: buildCubit,
        act: (cubit) => cubit.load(invalidId),
        expect: () => [
          const PublicGroupState(status: PublicGroupStatus.unavailable),
        ],
        verify: (_) => verifyNever(() => repository.getGroup(any())),
      );
    }

    blocTest<PublicGroupCubit, PublicGroupState>(
      'emits unavailable when the group is not available',
      setUp: () => when(
        () => repository.getGroup(groupId),
      ).thenAnswer((_) async => const Failure(GroupUnavailableFailure())),
      build: buildCubit,
      act: (cubit) => cubit.load(groupId),
      expect: () => [
        const PublicGroupState(),
        const PublicGroupState(status: PublicGroupStatus.unavailable),
      ],
    );

    blocTest<PublicGroupCubit, PublicGroupState>(
      'emits the error and loads the same group on retry',
      setUp: () => when(
        () => repository.getGroup(groupId),
      ).thenAnswer((_) async => const Failure(GroupDiscoveryNetworkFailure())),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.retry();
      },
      expect: () => [
        const PublicGroupState(),
        const PublicGroupState(
          status: PublicGroupStatus.error,
          failure: GroupDiscoveryNetworkFailure(),
        ),
        const PublicGroupState(),
        const PublicGroupState(
          status: PublicGroupStatus.error,
          failure: GroupDiscoveryNetworkFailure(),
        ),
      ],
      verify: (_) => verify(() => repository.getGroup(groupId)).called(2),
    );
  });

  group('requestJoin', () {
    blocTest<PublicGroupCubit, PublicGroupState>(
      'marks the group as requested and signals the success',
      setUp: () => when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) async {
        await cubit.requestJoin();
        cubit.clearJoinFeedback();
      },
      expect: () => [
        loaded.copyWith(isRequesting: true),
        loaded.copyWith(
          group: noneGroup.copyWith(
            membershipStatus: GroupMembershipStatus.requested,
          ),
          joinRequested: true,
        ),
        loaded.copyWith(
          group: noneGroup.copyWith(
            membershipStatus: GroupMembershipStatus.requested,
          ),
        ),
      ],
    );

    blocTest<PublicGroupCubit, PublicGroupState>(
      'reloads the group when the backend says it was already requested, '
      'busy until the real status arrives',
      setUp: () {
        when(() => repository.requestJoin(groupId)).thenAnswer(
          (_) async => const Failure(GroupJoinAlreadyRequestedFailure()),
        );
        when(() => repository.getGroup(groupId)).thenAnswer(
          (_) async => Success(
            noneGroup.copyWith(membershipStatus: GroupMembershipStatus.member),
          ),
        );
      },
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestJoin(),
      expect: () => [
        loaded.copyWith(isRequesting: true),
        loaded.copyWith(
          isRequesting: true,
          joinFailure: const GroupJoinAlreadyRequestedFailure(),
        ),
        loaded.copyWith(
          group: noneGroup.copyWith(
            membershipStatus: GroupMembershipStatus.member,
          ),
          joinFailure: const GroupJoinAlreadyRequestedFailure(),
        ),
      ],
      verify: (_) => verify(() => repository.getGroup(groupId)).called(1),
    );

    blocTest<PublicGroupCubit, PublicGroupState>(
      'frees the button and keeps the group when that reload fails',
      setUp: () {
        when(() => repository.requestJoin(groupId)).thenAnswer(
          (_) async => const Failure(GroupJoinAlreadyRequestedFailure()),
        );
        when(() => repository.getGroup(groupId)).thenAnswer(
          (_) async => const Failure(GroupDiscoveryNetworkFailure()),
        );
      },
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestJoin(),
      expect: () => [
        loaded.copyWith(isRequesting: true),
        loaded.copyWith(
          isRequesting: true,
          joinFailure: const GroupJoinAlreadyRequestedFailure(),
        ),
        loaded.copyWith(joinFailure: const GroupJoinAlreadyRequestedFailure()),
      ],
    );

    blocTest<PublicGroupCubit, PublicGroupState>(
      'shows the unavailable state when the group is gone on that reload',
      setUp: () {
        when(() => repository.requestJoin(groupId)).thenAnswer(
          (_) async => const Failure(GroupJoinAlreadyRequestedFailure()),
        );
        when(
          () => repository.getGroup(groupId),
        ).thenAnswer((_) async => const Failure(GroupUnavailableFailure()));
      },
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestJoin(),
      expect: () => [
        loaded.copyWith(isRequesting: true),
        loaded.copyWith(
          isRequesting: true,
          joinFailure: const GroupJoinAlreadyRequestedFailure(),
        ),
        const PublicGroupState(status: PublicGroupStatus.unavailable),
      ],
    );

    test('a double tap sends a single request', () async {
      final pending = Completer<Result<void, GroupDiscoveryFailure>>();
      when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) => pending.future);
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final first = cubit.requestJoin();
      final second = cubit.requestJoin();
      pending.complete(const Success(null));
      await Future.wait([first, second]);

      verify(() => repository.requestJoin(groupId)).called(1);
      expect(
        cubit.state.group?.membershipStatus,
        GroupMembershipStatus.requested,
      );
    });

    test('does nothing after the screen closed', () async {
      final cubit = buildCubit()..emit(loaded);
      await cubit.close();

      await cubit.requestJoin();

      verifyNever(() => repository.requestJoin(any()));
    });

    blocTest<PublicGroupCubit, PublicGroupState>(
      'keeps the group and signals any other failure',
      setUp: () => when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Failure(GroupJoinNoCoordinatorFailure())),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestJoin(),
      expect: () => [
        loaded.copyWith(isRequesting: true),
        loaded.copyWith(joinFailure: const GroupJoinNoCoordinatorFailure()),
      ],
      verify: (_) => verifyNever(() => repository.getGroup(any())),
    );

    blocTest<PublicGroupCubit, PublicGroupState>(
      'shows unavailable when the group stopped accepting this reader',
      setUp: () => when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Failure(GroupUnavailableFailure())),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestJoin(),
      expect: () => [
        loaded.copyWith(isRequesting: true),
        const PublicGroupState(status: PublicGroupStatus.unavailable),
      ],
    );

    blocTest<PublicGroupCubit, PublicGroupState>(
      'asks again after a rejection',
      setUp: () => when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Success(null)),
      build: buildCubit,
      seed: () => PublicGroupState(
        status: PublicGroupStatus.loaded,
        group: discoveryGroup(membership: GroupMembershipStatus.rejected),
      ),
      act: (cubit) => cubit.requestJoin(),
      verify: (cubit) => expect(
        cubit.state.group?.membershipStatus,
        GroupMembershipStatus.requested,
      ),
    );

    for (final status in [
      GroupMembershipStatus.requested,
      GroupMembershipStatus.pending,
      GroupMembershipStatus.member,
    ]) {
      blocTest<PublicGroupCubit, PublicGroupState>(
        'does not ask when the reader is ${status.name}',
        build: buildCubit,
        seed: () => PublicGroupState(
          status: PublicGroupStatus.loaded,
          group: discoveryGroup(membership: status),
        ),
        act: (cubit) => cubit.requestJoin(),
        expect: () => <PublicGroupState>[],
        verify: (_) => verifyNever(() => repository.requestJoin(any())),
      );
    }

    blocTest<PublicGroupCubit, PublicGroupState>(
      'ignores a second tap while the first request runs',
      build: buildCubit,
      seed: () => loaded.copyWith(isRequesting: true),
      act: (cubit) => cubit.requestJoin(),
      expect: () => <PublicGroupState>[],
      verify: (_) => verifyNever(() => repository.requestJoin(any())),
    );
  });
}
