import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_participant_model.dart';
import 'package:mobile/features/groups/data/repositories/group_participants_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late GroupParticipantsRepositoryImpl repository;

  const functionName = 'get-group-participants?group_id=group-1';

  void answerWith(Object? json) {
    when(
      () => mockSupabaseService.invokeFunction<List<GroupParticipantModel>>(
        functionName: functionName,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as List<GroupParticipantModel> Function(dynamic);
      return Success<
        SupabaseResponse<List<GroupParticipantModel>>,
        SupabaseFailure
      >(SupabaseResponse(data: json == null ? null : decoder(json)));
    });
  }

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = GroupParticipantsRepositoryImpl(
      supabaseService: mockSupabaseService,
    );
  });

  test(
    'given participants, when fetched, then puts coordinators first and '
    'sorts the rest alphabetically ignoring accents and case',
    () async {
      answerWith(const {
        'participants': [
          {'id': '1', 'name': 'bruna'},
          {'id': '2', 'name': 'Zélia', 'role': 'coordinator'},
          {'id': '3', 'name': 'Ágata'},
          {'id': '4', 'name': 'Carla'},
        ],
      });

      final result = await repository.getParticipants('group-1');

      expect(result.unwrap().map((p) => p.name), [
        'Zélia',
        'Ágata',
        'bruna',
        'Carla',
      ]);
    },
  );

  test('given the function fails, then returns a participants failure', () async {
    const failure = FunctionSupabaseFailure(message: 'boom', code: '500');
    when(
      () => mockSupabaseService.invokeFunction<List<GroupParticipantModel>>(
        functionName: functionName,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => const Failure(failure));

    final result = await repository.getParticipants('group-1');

    expect(
      result,
      isA<Failure<List<GroupParticipantEntity>, GroupFailure>>().having(
        (f) => f.failure,
        'failure',
        const GroupParticipantsFailure(),
      ),
    );
  });

  test('given an empty body, then returns a participants failure', () async {
    answerWith(null);

    final result = await repository.getParticipants('group-1');

    expect(
      result,
      const Failure<List<GroupParticipantEntity>, GroupFailure>(
        GroupParticipantsFailure(),
      ),
    );
  });
}
