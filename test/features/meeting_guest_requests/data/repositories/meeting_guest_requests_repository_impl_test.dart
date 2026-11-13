import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/meeting_guest_requests/data/models/meeting_guest_request_model.dart';
import 'package:mobile/features/meeting_guest_requests/data/repositories/meeting_guest_requests_repository_impl.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../meeting_guest_requests_fixtures.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

FunctionSupabaseFailure _backendError(int status, String error) =>
    FunctionSupabaseFailure(
      message: error,
      code: '$status',
      kind: SupabaseFailureKind.fromStatusCode(status),
    );

const _networkError = FunctionSupabaseFailure(
  message: 'Failed host lookup',
  kind: SupabaseFailureKind.network,
);

void main() {
  late MockSupabaseService service;
  late MeetingGuestRequestsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    service = MockSupabaseService();
    repository = MeetingGuestRequestsRepositoryImpl(supabaseService: service);
  });

  group('getRequests', () {
    void stub(
      Result<SupabaseResponse<List<MeetingGuestRequestModel>>, SupabaseFailure>
      result,
    ) {
      when(
        () => service.invokeFunction<List<MeetingGuestRequestModel>>(
          functionName: any(named: 'functionName'),
          method: any(named: 'method'),
          queryParameters: any(named: 'queryParameters'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    Future<Result<List<MeetingGuestRequestEntity>, MeetingGuestRequestsFailure>>
    get() => repository.getRequests(meetingId);

    test(
      'GETs get-meeting-guest-requests with meeting_id and returns the list',
      () async {
        stub(
          Success(
            SupabaseResponse(
              data: [MeetingGuestRequestModel.fromJson(guestRequestJson())],
            ),
          ),
        );

        final result = await get();

        expect(result.unwrap(), [anaRequest]);
        final call = verify(
          () => service.invokeFunction<List<MeetingGuestRequestModel>>(
            functionName: 'get-meeting-guest-requests',
            method: HttpMethod.get,
            queryParameters: {'meeting_id': meetingId},
            decoder: captureAny(named: 'decoder'),
          ),
        )..called(1);
        final decoder =
            call.captured.single
                as List<MeetingGuestRequestModel> Function(dynamic);
        expect(
          decoder({
            'requests': [guestRequestJson()],
          }).single.toDomain(),
          anaRequest,
        );
      },
    );

    test('an empty list is a success', () async {
      stub(const Success(SupabaseResponse(data: [])));

      expect(
        await get(),
        const Success<
          List<MeetingGuestRequestEntity>,
          MeetingGuestRequestsFailure
        >([]),
      );
    });

    test('a response without data is a server failure', () async {
      stub(const Success(SupabaseResponse()));

      expect(
        await get(),
        const Failure<
          List<MeetingGuestRequestEntity>,
          MeetingGuestRequestsFailure
        >(MeetingGuestRequestsServerFailure()),
      );
    });

    final cases = <String, (SupabaseFailure, MeetingGuestRequestsFailure)>{
      'network': (_networkError, const MeetingGuestRequestsNetworkFailure()),
      '400': (
        _backendError(400, 'missing/invalid "meeting_id"'),
        const MeetingGuestRequestsInvalidFailure(),
      ),
      '401': (
        _backendError(401, 'Unauthorized'),
        const MeetingGuestRequestsSessionExpiredFailure(),
      ),
      '403': (
        _backendError(403, 'Forbidden: meeting reviewers only'),
        const MeetingGuestRequestsNotReviewerFailure(),
      ),
      '500': (
        _backendError(500, 'Unable to load meeting guest requests'),
        const MeetingGuestRequestsServerFailure(),
      ),
    };
    for (final MapEntry(key: name, value: (backend, expected))
        in cases.entries) {
      test('maps $name to ${expected.runtimeType}', () async {
        stub(Failure(backend));

        expect(
          await get(),
          Failure<List<MeetingGuestRequestEntity>, MeetingGuestRequestsFailure>(
            expected,
          ),
        );
      });
    }
  });

  group('review', () {
    void stub(Result<SupabaseResponse<void>, SupabaseFailure> result) {
      when(
        () => service.invokeFunction<void>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => result);
    }

    for (final (decision, action) in [
      (GuestRequestDecision.approve, 'approve'),
      (GuestRequestDecision.reject, 'reject'),
    ]) {
      test(
        'POSTs review-meeting-guest-request with action "$action"',
        () async {
          stub(const Success(SupabaseResponse()));

          final result = await repository.review(
            requestId: anaRequestId,
            decision: decision,
          );

          expect(result, isA<Success<void, MeetingGuestRequestsFailure>>());
          verify(
            () => service.invokeFunction<void>(
              functionName: 'review-meeting-guest-request',
              body: {'request_id': anaRequestId, 'action': action},
            ),
          ).called(1);
        },
      );
    }

    final cases = <String, (SupabaseFailure, MeetingGuestRequestsFailure)>{
      'network': (_networkError, const MeetingGuestRequestsNetworkFailure()),
      '400': (
        _backendError(400, 'missing/invalid "request_id"'),
        const MeetingGuestRequestsInvalidFailure(),
      ),
      '401': (
        _backendError(401, 'Unauthorized'),
        const MeetingGuestRequestsSessionExpiredFailure(),
      ),
      '404 request not found': (
        _backendError(404, 'request not found'),
        const GuestRequestNotFoundFailure(),
      ),
      '404 without the request message': (
        _backendError(404, 'User profile not found'),
        const MeetingGuestRequestsServerFailure(),
      ),
      '409 already reviewed': (
        _backendError(409, 'request already reviewed'),
        const GuestRequestAlreadyReviewedFailure(),
      ),
      '409 no longer valid': (
        _backendError(409, 'request no longer valid'),
        const GuestRequestNoLongerValidFailure(),
      ),
      '409 with an unknown message': (
        _backendError(409, 'something else'),
        const MeetingGuestRequestsServerFailure(),
      ),
      '500': (
        _backendError(500, 'Unable to review meeting guest request'),
        const MeetingGuestRequestsServerFailure(),
      ),
    };
    for (final MapEntry(key: name, value: (backend, expected))
        in cases.entries) {
      test('maps $name to ${expected.runtimeType}', () async {
        stub(Failure(backend));

        expect(
          await repository.review(
            requestId: anaRequestId,
            decision: GuestRequestDecision.approve,
          ),
          Failure<void, MeetingGuestRequestsFailure>(expected),
        );
      });
    }
  });
}
