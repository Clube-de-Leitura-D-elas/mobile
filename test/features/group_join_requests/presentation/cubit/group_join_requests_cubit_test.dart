import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mobile/features/group_join_requests/domain/repository/group_join_requests_repository.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_join_requests_fixtures.dart';

class MockGroupJoinRequestsRepository extends Mock
    implements GroupJoinRequestsRepository {}

void main() {
  late MockGroupJoinRequestsRepository repository;

  final loaded = GroupJoinRequestsState(
    status: GroupJoinRequestsStatus.loaded,
    requests: [anaRequest, biaRequest],
  );

  setUpAll(() {
    registerFallbackValue(JoinRequestDecision.approve);
  });

  setUp(() {
    repository = MockGroupJoinRequestsRepository();
  });

  GroupJoinRequestsCubit buildCubit() =>
      GroupJoinRequestsCubit(repository: repository);

  void stubRequests(List<Object> responses) {
    var call = 0;
    when(() => repository.getRequests(groupId)).thenAnswer((_) async {
      final response =
          responses[call < responses.length ? call : responses.length - 1];
      call++;
      return switch (response) {
        final GroupJoinRequestsFailure failure => Failure(failure),
        final List<Object> list => Success(list.cast()),
        _ => throw ArgumentError(response),
      };
    });
  }

  void stubReview(
    JoinRequestDecision decision,
    Result<void, GroupJoinRequestsFailure> result,
  ) {
    when(
      () => repository.review(requestId: anaRequestId, decision: decision),
    ).thenAnswer((_) async => result);
  }

  group('load', () {
    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'emits loading and the requests',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
      ]),
      build: buildCubit,
      act: (cubit) => cubit.load(groupId),
      expect: () => [const GroupJoinRequestsState(), loaded],
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'emits loaded with an empty list',
      setUp: () => stubRequests([<Object>[]]),
      build: buildCubit,
      act: (cubit) => cubit.load(groupId),
      expect: () => [
        const GroupJoinRequestsState(),
        const GroupJoinRequestsState(status: GroupJoinRequestsStatus.loaded),
      ],
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'a 403 means the reader is not a coordinator',
      setUp: () =>
          stubRequests([const GroupJoinRequestsNotCoordinatorFailure()]),
      build: buildCubit,
      act: (cubit) => cubit.load(groupId),
      expect: () => [
        const GroupJoinRequestsState(),
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.notCoordinator,
        ),
      ],
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'emits the error and loads the same group on retry',
      setUp: () => stubRequests([
        const GroupJoinRequestsNetworkFailure(),
        [anaRequest, biaRequest],
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.retry();
      },
      expect: () => [
        const GroupJoinRequestsState(),
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.error,
          failure: GroupJoinRequestsNetworkFailure(),
        ),
        const GroupJoinRequestsState(),
        loaded,
      ],
      verify: (_) => verify(() => repository.getRequests(groupId)).called(2),
    );

    for (final invalidId in ['', 'abc']) {
      blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
        'does not ask the backend for the id "$invalidId"',
        build: buildCubit,
        act: (cubit) => cubit.load(invalidId),
        expect: () => [
          const GroupJoinRequestsState(
            status: GroupJoinRequestsStatus.error,
            failure: GroupJoinRequestsInvalidFailure(),
          ),
        ],
        verify: (_) => verifyNever(() => repository.getRequests(any())),
      );
    }
  });

  group('refresh', () {
    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'updates the list without going through loading',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
        [biaRequest],
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
        ),
      ],
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'keeps the list when the refresh fails',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
        const GroupJoinRequestsNetworkFailure(),
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.refresh();
      },
      skip: 2,
      expect: () => <GroupJoinRequestsState>[],
      verify: (cubit) => expect(cubit.state, loaded),
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'hides the list when the reader stopped being a coordinator',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
        const GroupJoinRequestsNotCoordinatorFailure(),
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.notCoordinator,
        ),
      ],
    );
  });

  group('review', () {
    final reviewingApprove = loaded.copyWith(
      reviewingId: anaRequestId,
      reviewingDecision: JoinRequestDecision.approve,
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'approving removes the request and reports it',
      setUp: () => stubReview(JoinRequestDecision.approve, const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve(anaRequestId),
      expect: () => [
        reviewingApprove,
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: JoinRequestReviewOutcome.approved,
        ),
      ],
      verify: (_) => verify(
        () => repository.review(
          requestId: anaRequestId,
          decision: JoinRequestDecision.approve,
        ),
      ).called(1),
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'rejecting removes the request and reports it',
      setUp: () => stubReview(JoinRequestDecision.reject, const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.reject(anaRequestId),
      expect: () => [
        loaded.copyWith(
          reviewingId: anaRequestId,
          reviewingDecision: JoinRequestDecision.reject,
        ),
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: JoinRequestReviewOutcome.rejected,
        ),
      ],
      verify: (_) => verify(
        () => repository.review(
          requestId: anaRequestId,
          decision: JoinRequestDecision.reject,
        ),
      ).called(1),
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'a request already reviewed by another coordinator leaves the list',
      setUp: () => stubReview(
        JoinRequestDecision.approve,
        const Failure(JoinRequestAlreadyReviewedFailure()),
      ),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve(anaRequestId),
      expect: () => [
        reviewingApprove,
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: JoinRequestReviewOutcome.alreadyReviewed,
        ),
      ],
      verify: (_) => verifyNever(() => repository.getRequests(any())),
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'a request no longer valid is reported and the list reloads',
      setUp: () {
        stubReview(
          JoinRequestDecision.approve,
          const Failure(JoinRequestNoLongerValidFailure()),
        );
        stubRequests([
          [anaRequest, biaRequest],
          [biaRequest],
        ]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.approve(anaRequestId);
      },
      skip: 2,
      expect: () => [
        reviewingApprove,
        reviewingApprove.copyWith(
          reviewOutcome: JoinRequestReviewOutcome.noLongerValid,
        ),
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: JoinRequestReviewOutcome.noLongerValid,
        ),
      ],
      verify: (_) => verify(() => repository.getRequests(groupId)).called(2),
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'a request not found leaves the list and the list reloads',
      setUp: () {
        stubReview(
          JoinRequestDecision.approve,
          const Failure(JoinRequestNotFoundFailure()),
        );
        stubRequests([
          [anaRequest, biaRequest],
          const GroupJoinRequestsNotCoordinatorFailure(),
        ]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(groupId);
        await cubit.approve(anaRequestId);
      },
      skip: 2,
      expect: () => [
        reviewingApprove,
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
          reviewingId: anaRequestId,
          reviewingDecision: JoinRequestDecision.approve,
          reviewOutcome: JoinRequestReviewOutcome.notFound,
        ),
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.notCoordinator,
          reviewOutcome: JoinRequestReviewOutcome.notFound,
        ),
      ],
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'a failure keeps the request and reports why',
      setUp: () => stubReview(
        JoinRequestDecision.approve,
        const Failure(GroupJoinRequestsNetworkFailure()),
      ),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve(anaRequestId),
      expect: () => [
        reviewingApprove,
        GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [anaRequest, biaRequest],
          reviewOutcome: JoinRequestReviewOutcome.failed,
          reviewFailure: const GroupJoinRequestsNetworkFailure(),
        ),
      ],
    );

    test('a second tap while deciding does not send again', () async {
      final response = Completer<Result<void, GroupJoinRequestsFailure>>();
      when(
        () => repository.review(
          requestId: any(named: 'requestId'),
          decision: any(named: 'decision'),
        ),
      ).thenAnswer((_) => response.future);
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final first = cubit.approve(anaRequestId);
      await cubit.approve(anaRequestId);
      await cubit.reject(biaRequestId);
      response.complete(const Success(null));
      await first;

      verify(
        () => repository.review(
          requestId: anaRequestId,
          decision: JoinRequestDecision.approve,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
      expect(cubit.state.requests, [biaRequest]);
    });

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'ignores a request that is not on the list',
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve('44444444-4444-4444-4444-444444444444'),
      expect: () => <GroupJoinRequestsState>[],
      verify: (_) => verifyNever(
        () => repository.review(
          requestId: any(named: 'requestId'),
          decision: any(named: 'decision'),
        ),
      ),
    );

    blocTest<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      'clearReviewFeedback removes the one-time feedback',
      build: buildCubit,
      seed: () => const GroupJoinRequestsState(
        status: GroupJoinRequestsStatus.loaded,
        requests: [biaRequest],
        reviewOutcome: JoinRequestReviewOutcome.failed,
        reviewFailure: GroupJoinRequestsNetworkFailure(),
      ),
      act: (cubit) => cubit.clearReviewFeedback(),
      expect: () => [
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.loaded,
          requests: [biaRequest],
        ),
      ],
    );
  });
}
