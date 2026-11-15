import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';
import 'package:mobile/features/meeting_guest_requests/domain/repository/meeting_guest_requests_repository.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../meeting_guest_requests_fixtures.dart';

class MockMeetingGuestRequestsRepository extends Mock
    implements MeetingGuestRequestsRepository {}

void main() {
  late MockMeetingGuestRequestsRepository repository;

  final loaded = MeetingGuestRequestsState(
    status: MeetingGuestRequestsStatus.loaded,
    requests: [anaRequest, biaRequest],
  );

  setUpAll(() {
    registerFallbackValue(GuestRequestDecision.approve);
  });

  setUp(() {
    repository = MockMeetingGuestRequestsRepository();
  });

  MeetingGuestRequestsCubit buildCubit() =>
      MeetingGuestRequestsCubit(repository: repository);

  void stubRequests(List<Object> responses) {
    var call = 0;
    when(() => repository.getRequests(meetingId)).thenAnswer((_) async {
      final response =
          responses[call < responses.length ? call : responses.length - 1];
      call++;
      return switch (response) {
        final MeetingGuestRequestsFailure failure => Failure(failure),
        final List<Object> list => Success(list.cast()),
        _ => throw ArgumentError(response),
      };
    });
  }

  void stubReview(
    GuestRequestDecision decision,
    Result<void, MeetingGuestRequestsFailure> result,
  ) {
    when(
      () => repository.review(requestId: anaRequestId, decision: decision),
    ).thenAnswer((_) async => result);
  }

  group('load', () {
    test('a slower earlier read does not overwrite the latest one', () async {
      final first =
          Completer<
            Result<List<MeetingGuestRequestEntity>, MeetingGuestRequestsFailure>
          >();
      final second =
          Completer<
            Result<List<MeetingGuestRequestEntity>, MeetingGuestRequestsFailure>
          >();
      final reads = [first, second];
      var call = 0;
      when(
        () => repository.getRequests(meetingId),
      ).thenAnswer((_) => reads[call++].future);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final initial = cubit.load(meetingId);
      final retry = cubit.retry();
      second.complete(Success([anaRequest]));
      await retry;
      first.complete(const Failure(MeetingGuestRequestsNetworkFailure()));
      await initial;

      expect(cubit.state.status, MeetingGuestRequestsStatus.loaded);
      expect(cubit.state.requests, [anaRequest]);
    });

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'emits loading and the requests',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
      ]),
      build: buildCubit,
      act: (cubit) => cubit.load(meetingId),
      expect: () => [const MeetingGuestRequestsState(), loaded],
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'emits loaded with an empty list',
      setUp: () => stubRequests([<Object>[]]),
      build: buildCubit,
      act: (cubit) => cubit.load(meetingId),
      expect: () => [
        const MeetingGuestRequestsState(),
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
        ),
      ],
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'a 403 means the reader cannot decide the meeting requests',
      setUp: () =>
          stubRequests([const MeetingGuestRequestsNotReviewerFailure()]),
      build: buildCubit,
      act: (cubit) => cubit.load(meetingId),
      expect: () => [
        const MeetingGuestRequestsState(),
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.notReviewer,
        ),
      ],
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'emits the error and loads the same meeting on retry',
      setUp: () => stubRequests([
        const MeetingGuestRequestsNetworkFailure(),
        [anaRequest, biaRequest],
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(meetingId);
        await cubit.retry();
      },
      expect: () => [
        const MeetingGuestRequestsState(),
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.error,
          failure: MeetingGuestRequestsNetworkFailure(),
        ),
        const MeetingGuestRequestsState(),
        loaded,
      ],
      verify: (_) => verify(() => repository.getRequests(meetingId)).called(2),
    );

    for (final invalidId in ['', 'abc']) {
      blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
        'does not ask the backend for the id "$invalidId"',
        build: buildCubit,
        act: (cubit) => cubit.load(invalidId),
        expect: () => [
          const MeetingGuestRequestsState(
            status: MeetingGuestRequestsStatus.error,
            failure: MeetingGuestRequestsInvalidFailure(),
          ),
        ],
        verify: (_) => verifyNever(() => repository.getRequests(any())),
      );
    }
  });

  group('refresh', () {
    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'updates the list without going through loading',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
        [biaRequest],
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(meetingId);
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
        ),
      ],
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'keeps the list when the refresh fails',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
        const MeetingGuestRequestsNetworkFailure(),
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(meetingId);
        await cubit.refresh();
      },
      skip: 2,
      expect: () => <MeetingGuestRequestsState>[],
      verify: (cubit) => expect(cubit.state, loaded),
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'hides the list when the reader can no longer decide',
      setUp: () => stubRequests([
        [anaRequest, biaRequest],
        const MeetingGuestRequestsNotReviewerFailure(),
      ]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(meetingId);
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.notReviewer,
        ),
      ],
    );
  });

  group('review', () {
    final reviewingApprove = loaded.copyWith(
      reviewingId: anaRequestId,
      reviewingDecision: GuestRequestDecision.approve,
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'approving removes the request and reports it',
      setUp: () =>
          stubReview(GuestRequestDecision.approve, const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve(anaRequestId),
      expect: () => [
        reviewingApprove,
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: GuestRequestReviewOutcome.approved,
        ),
      ],
      verify: (_) => verify(
        () => repository.review(
          requestId: anaRequestId,
          decision: GuestRequestDecision.approve,
        ),
      ).called(1),
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'rejecting removes the request and reports it',
      setUp: () => stubReview(GuestRequestDecision.reject, const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.reject(anaRequestId),
      expect: () => [
        loaded.copyWith(
          reviewingId: anaRequestId,
          reviewingDecision: GuestRequestDecision.reject,
        ),
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: GuestRequestReviewOutcome.rejected,
        ),
      ],
      verify: (_) => verify(
        () => repository.review(
          requestId: anaRequestId,
          decision: GuestRequestDecision.reject,
        ),
      ).called(1),
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'a request already reviewed by someone else leaves the list',
      setUp: () => stubReview(
        GuestRequestDecision.approve,
        const Failure(GuestRequestAlreadyReviewedFailure()),
      ),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve(anaRequestId),
      expect: () => [
        reviewingApprove,
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: GuestRequestReviewOutcome.alreadyReviewed,
        ),
      ],
      verify: (_) => verifyNever(() => repository.getRequests(any())),
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'a request no longer valid is reported and the list reloads',
      setUp: () {
        stubReview(
          GuestRequestDecision.approve,
          const Failure(GuestRequestNoLongerValidFailure()),
        );
        stubRequests([
          [anaRequest, biaRequest],
          [biaRequest],
        ]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(meetingId);
        await cubit.approve(anaRequestId);
      },
      skip: 2,
      expect: () => [
        reviewingApprove,
        reviewingApprove.copyWith(
          reviewOutcome: GuestRequestReviewOutcome.noLongerValid,
        ),
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
          reviewOutcome: GuestRequestReviewOutcome.noLongerValid,
        ),
      ],
      verify: (_) => verify(() => repository.getRequests(meetingId)).called(2),
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'a request not found leaves the list and the list reloads',
      setUp: () {
        stubReview(
          GuestRequestDecision.approve,
          const Failure(GuestRequestNotFoundFailure()),
        );
        stubRequests([
          [anaRequest, biaRequest],
          const MeetingGuestRequestsNotReviewerFailure(),
        ]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(meetingId);
        await cubit.approve(anaRequestId);
      },
      skip: 2,
      expect: () => [
        reviewingApprove,
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
          reviewingId: anaRequestId,
          reviewingDecision: GuestRequestDecision.approve,
          reviewOutcome: GuestRequestReviewOutcome.notFound,
        ),
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.notReviewer,
          reviewOutcome: GuestRequestReviewOutcome.notFound,
        ),
      ],
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'a failure keeps the request and reports why',
      setUp: () => stubReview(
        GuestRequestDecision.approve,
        const Failure(MeetingGuestRequestsNetworkFailure()),
      ),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve(anaRequestId),
      expect: () => [
        reviewingApprove,
        MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [anaRequest, biaRequest],
          reviewOutcome: GuestRequestReviewOutcome.failed,
          reviewFailure: const MeetingGuestRequestsNetworkFailure(),
        ),
      ],
    );

    test('a second tap while deciding does not send again', () async {
      final response = Completer<Result<void, MeetingGuestRequestsFailure>>();
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
          decision: GuestRequestDecision.approve,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
      expect(cubit.state.requests, [biaRequest]);
    });

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'ignores a request that is not on the list',
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.approve('44444444-4444-4444-4444-444444444444'),
      expect: () => <MeetingGuestRequestsState>[],
      verify: (_) => verifyNever(
        () => repository.review(
          requestId: any(named: 'requestId'),
          decision: any(named: 'decision'),
        ),
      ),
    );

    blocTest<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
      'clearReviewFeedback removes the one-time feedback',
      build: buildCubit,
      seed: () => const MeetingGuestRequestsState(
        status: MeetingGuestRequestsStatus.loaded,
        requests: [biaRequest],
        reviewOutcome: GuestRequestReviewOutcome.failed,
        reviewFailure: MeetingGuestRequestsNetworkFailure(),
      ),
      act: (cubit) => cubit.clearReviewFeedback(),
      expect: () => [
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.loaded,
          requests: [biaRequest],
        ),
      ],
    );
  });
}
