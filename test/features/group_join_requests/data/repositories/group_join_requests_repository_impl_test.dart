import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_join_requests/data/models/group_join_request_model.dart';
import 'package:mobile/features/group_join_requests/data/repositories/group_join_requests_repository_impl.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../group_join_requests_fixtures.dart';

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
  late GroupJoinRequestsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    service = MockSupabaseService();
    repository = GroupJoinRequestsRepositoryImpl(supabaseService: service);
  });

  group('getRequests', () {
    void stub(
      Result<SupabaseResponse<List<GroupJoinRequestModel>>, SupabaseFailure>
      result,
    ) {
      when(
        () => service.invokeFunction<List<GroupJoinRequestModel>>(
          functionName: any(named: 'functionName'),
          method: any(named: 'method'),
          queryParameters: any(named: 'queryParameters'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    Future<Result<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>>
    get() => repository.getRequests(groupId);

    test(
      'GETs get-group-join-requests with group_id and returns the list',
      () async {
        stub(
          Success(
            SupabaseResponse(
              data: [GroupJoinRequestModel.fromJson(joinRequestJson())],
            ),
          ),
        );

        final result = await get();

        expect(result.unwrap(), [anaRequest]);
        final call = verify(
          () => service.invokeFunction<List<GroupJoinRequestModel>>(
            functionName: 'get-group-join-requests',
            method: HttpMethod.get,
            queryParameters: {'group_id': groupId},
            decoder: captureAny(named: 'decoder'),
          ),
        )..called(1);
        final decoder =
            call.captured.single
                as List<GroupJoinRequestModel> Function(dynamic);
        expect(
          decoder({
            'requests': [joinRequestJson()],
          }).single.toDomain(),
          anaRequest,
        );
      },
    );

    test('an empty list is a success', () async {
      stub(const Success(SupabaseResponse(data: [])));

      expect(
        await get(),
        const Success<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>(
          [],
        ),
      );
    });

    test('a response without data is a server failure', () async {
      stub(const Success(SupabaseResponse()));

      expect(
        await get(),
        const Failure<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>(
          GroupJoinRequestsServerFailure(),
        ),
      );
    });

    final cases = <String, (SupabaseFailure, GroupJoinRequestsFailure)>{
      'network': (_networkError, const GroupJoinRequestsNetworkFailure()),
      '400': (
        _backendError(400, 'missing/invalid "group_id"'),
        const GroupJoinRequestsInvalidFailure(),
      ),
      '401': (
        _backendError(401, 'Unauthorized'),
        const GroupJoinRequestsSessionExpiredFailure(),
      ),
      '403': (
        _backendError(403, 'Forbidden: group coordinators only'),
        const GroupJoinRequestsNotCoordinatorFailure(),
      ),
      '500': (
        _backendError(500, 'Unable to load group join requests'),
        const GroupJoinRequestsServerFailure(),
      ),
    };
    for (final MapEntry(key: name, value: (backend, expected))
        in cases.entries) {
      test('maps $name to ${expected.runtimeType}', () async {
        stub(Failure(backend));

        expect(
          await get(),
          Failure<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>(
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
      (JoinRequestDecision.approve, 'approve'),
      (JoinRequestDecision.reject, 'reject'),
    ]) {
      test('POSTs review-group-join-request with action "$action"', () async {
        stub(const Success(SupabaseResponse()));

        final result = await repository.review(
          requestId: anaRequestId,
          decision: decision,
        );

        expect(result, isA<Success<void, GroupJoinRequestsFailure>>());
        verify(
          () => service.invokeFunction<void>(
            functionName: 'review-group-join-request',
            body: {'group_user_id': anaRequestId, 'action': action},
          ),
        ).called(1);
      });
    }

    final cases = <String, (SupabaseFailure, GroupJoinRequestsFailure)>{
      'network': (_networkError, const GroupJoinRequestsNetworkFailure()),
      '400': (
        _backendError(400, 'missing/invalid "group_user_id"'),
        const GroupJoinRequestsInvalidFailure(),
      ),
      '401': (
        _backendError(401, 'Unauthorized'),
        const GroupJoinRequestsSessionExpiredFailure(),
      ),
      '404 request not found': (
        _backendError(404, 'request not found'),
        const JoinRequestNotFoundFailure(),
      ),
      '404 without the request message': (
        _backendError(404, 'User profile not found'),
        const GroupJoinRequestsServerFailure(),
      ),
      '409 already reviewed': (
        _backendError(409, 'request already reviewed'),
        const JoinRequestAlreadyReviewedFailure(),
      ),
      '409 no longer valid': (
        _backendError(409, 'request no longer valid'),
        const JoinRequestNoLongerValidFailure(),
      ),
      '409 with an unknown message': (
        _backendError(409, 'something else'),
        const GroupJoinRequestsServerFailure(),
      ),
      '500': (
        _backendError(500, 'Unable to review group join request'),
        const GroupJoinRequestsServerFailure(),
      ),
    };
    for (final MapEntry(key: name, value: (backend, expected))
        in cases.entries) {
      test('maps $name to ${expected.runtimeType}', () async {
        stub(Failure(backend));

        expect(
          await repository.review(
            requestId: anaRequestId,
            decision: JoinRequestDecision.approve,
          ),
          Failure<void, GroupJoinRequestsFailure>(expected),
        );
      });
    }
  });
}
