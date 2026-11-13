import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/data/models/discovery_group_model.dart';
import 'package:mobile/features/group_discovery/data/repositories/group_discovery_repository_impl.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../group_discovery_fixtures.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

FunctionSupabaseFailure _backendError(String status, String error) =>
    FunctionSupabaseFailure(
      message: error,
      code: status,
      kind: SupabaseFailureKind.fromStatusCode(int.parse(status)),
    );

void main() {
  late MockSupabaseService service;
  late GroupDiscoveryRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    service = MockSupabaseService();
    repository = GroupDiscoveryRepositoryImpl(supabaseService: service);
  });

  group('getGroup', () {
    void stub(
      Result<SupabaseResponse<List<DiscoveryGroupModel>>, SupabaseFailure>
      result,
    ) {
      when(
        () => service.invokeFunction<List<DiscoveryGroupModel>>(
          functionName: any(named: 'functionName'),
          method: any(named: 'method'),
          queryParameters: any(named: 'queryParameters'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    Future<Result<DiscoveryGroupEntity, GroupDiscoveryFailure>> get() =>
        repository.getGroup(groupId);

    test(
      'GETs get-city-groups filtered by groupId and returns the group',
      () async {
        stub(
          Success(
            SupabaseResponse(
              data: [DiscoveryGroupModel.fromJson(discoveryGroupJson())],
            ),
          ),
        );

        final result = await get();

        expect(result.unwrap().id, groupId);
        final call = verify(
          () => service.invokeFunction<List<DiscoveryGroupModel>>(
            functionName: 'get-city-groups',
            method: HttpMethod.get,
            queryParameters: {'groupId': groupId},
            decoder: captureAny(named: 'decoder'),
          ),
        )..called(1);
        final decoder =
            call.captured.single as List<DiscoveryGroupModel> Function(dynamic);
        expect(
          decoder({
            'items': [discoveryGroupJson()],
            'total': 1,
            'genres': <dynamic>[],
          }).single.number,
          1,
        );
      },
    );

    test(
      'a list without the requested group means it is unavailable',
      () async {
        // Backend sem o filtro `groupId` devolve os grupos da cidade.
        stub(
          Success(
            SupabaseResponse(
              data: [
                DiscoveryGroupModel.fromJson({
                  ...discoveryGroupJson(),
                  'id': '22222222-2222-2222-2222-222222222222',
                }),
              ],
            ),
          ),
        );

        expect(
          await get(),
          const Failure<DiscoveryGroupEntity, GroupDiscoveryFailure>(
            GroupUnavailableFailure(),
          ),
        );
      },
    );

    test('matches the group id regardless of letter case', () async {
      const lowerId = 'abcdef12-3456-4789-8abc-def123456789';
      stub(
        Success(
          SupabaseResponse(
            data: [
              DiscoveryGroupModel.fromJson({
                ...discoveryGroupJson(),
                'id': lowerId,
              }),
            ],
          ),
        ),
      );

      final result = await repository.getGroup(lowerId.toUpperCase());

      expect(result.unwrap().id, lowerId);
    });

    test('picks the requested group among others', () async {
      stub(
        Success(
          SupabaseResponse(
            data: [
              DiscoveryGroupModel.fromJson({
                ...discoveryGroupJson(),
                'id': '22222222-2222-2222-2222-222222222222',
                'number': 2,
              }),
              DiscoveryGroupModel.fromJson(discoveryGroupJson()),
            ],
          ),
        ),
      );

      final group = (await get()).unwrap();

      expect(group.id, groupId);
      expect(group.number, 1);
    });

    test('an empty list means the group is unavailable', () async {
      stub(const Success(SupabaseResponse(data: [])));

      expect(
        await get(),
        const Failure<DiscoveryGroupEntity, GroupDiscoveryFailure>(
          GroupUnavailableFailure(),
        ),
      );
    });

    final failures = <FunctionSupabaseFailure, GroupDiscoveryFailure>{
      const FunctionSupabaseFailure(
        message: 'offline',
        kind: SupabaseFailureKind.network,
      ): const GroupDiscoveryNetworkFailure(),
      _backendError('401', 'Unauthorized'):
          const GroupDiscoverySessionExpiredFailure(),
      _backendError('403', 'inactive account'):
          const GroupDiscoveryInactiveAccountFailure(),
      _backendError('404', 'User profile not found'):
          const GroupDiscoveryServerFailure(),
      _backendError('400', 'missing/invalid "groupId"'):
          const GroupUnavailableFailure(),
      _backendError('500', 'Unable to load groups'):
          const GroupDiscoveryServerFailure(),
    };
    for (final MapEntry(key: backend, value: expected) in failures.entries) {
      test('maps ${backend.code} "${backend.message}" to '
          '${expected.runtimeType}', () async {
        stub(Failure(backend));

        expect(
          await get(),
          Failure<DiscoveryGroupEntity, GroupDiscoveryFailure>(expected),
        );
      });
    }
  });

  group('requestJoin', () {
    void stub(Result<SupabaseResponse<void>, SupabaseFailure> result) {
      when(
        () => service.invokeFunction<void>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('POSTs the group id to request-group-join', () async {
      stub(const Success(SupabaseResponse(statusCode: 201)));

      final result = await repository.requestJoin(groupId);

      expect(result, isA<Success<void, GroupDiscoveryFailure>>());
      verify(
        () => service.invokeFunction<void>(
          functionName: 'request-group-join',
          body: {'group_id': groupId},
        ),
      ).called(1);
    });

    final failures = <FunctionSupabaseFailure, GroupDiscoveryFailure>{
      _backendError('401', 'Unauthorized'):
          const GroupDiscoverySessionExpiredFailure(),
      _backendError('404', 'group not found'): const GroupUnavailableFailure(),
      _backendError('404', 'User profile not found'):
          const GroupDiscoveryServerFailure(),
      _backendError('403', 'group not available'):
          const GroupUnavailableFailure(),
      _backendError('403', 'inactive account'):
          const GroupDiscoveryInactiveAccountFailure(),
      _backendError('409', 'already requested or member'):
          const GroupJoinAlreadyRequestedFailure(),
      _backendError('409', 'group has no coordinator'):
          const GroupJoinNoCoordinatorFailure(),
      _backendError('400', 'missing/invalid "group_id"'):
          const GroupDiscoveryServerFailure(),
      _backendError('500', 'Unable to request group join'):
          const GroupDiscoveryServerFailure(),
    };
    for (final MapEntry(key: backend, value: expected) in failures.entries) {
      test('maps ${backend.code} "${backend.message}" to '
          '${expected.runtimeType}', () async {
        stub(Failure(backend));

        expect(
          await repository.requestJoin(groupId),
          Failure<void, GroupDiscoveryFailure>(expected),
        );
      });
    }
  });
}
