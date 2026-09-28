import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late GroupRepositoryImpl repository;

  const groupJson = {
    'name': '45',
    'genres': ['Ficção', 'Aventura'],
    'participant_count': 34,
    'city': 'Porto Alegre',
    'state_code': 'RS',
    'cover_image_url': 'https://example.com/group-cover.jpg',
  };

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = GroupRepositoryImpl(supabaseService: mockSupabaseService);
  });

  test('maps the Edge Function JSON response to GroupDetailsEntity', () async {
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsEntity>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as GroupDetailsEntity Function(dynamic);
      final group = decoder(groupJson);

      return Success<SupabaseResponse<GroupDetailsEntity>, SupabaseFailure>(
        SupabaseResponse(data: group),
      );
    });

    final result = await repository.getGroupDetails('group-1');

    expect(
      result,
      const Success<GroupDetailsEntity, SupabaseFailure>(
        GroupDetailsEntity(
          name: '45',
          genres: ['Ficção', 'Aventura'],
          participantCount: 34,
          city: 'Porto Alegre',
          stateCode: 'RS',
          coverImageUrl: 'https://example.com/group-cover.jpg',
        ),
      ),
    );
    verify(
      () => mockSupabaseService.invokeFunction<GroupDetailsEntity>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).called(1);
  });

  test('returns Failure when the Edge Function call fails', () async {
    const failure = FunctionSupabaseFailure(message: 'Falha do servidor');
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsEntity>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => const Failure(failure));

    final result = await repository.getGroupDetails('group-1');

    expect(result, const Failure<GroupDetailsEntity, SupabaseFailure>(failure));
  });

  test('uses empty location values when response fields are null', () async {
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsEntity>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as GroupDetailsEntity Function(dynamic);
      final group = decoder({
        'name': '45',
        'genres': <String>[],
        'participant_count': 0,
        'city': null,
        'state_code': null,
        'cover_image_url': null,
      });

      return Success<SupabaseResponse<GroupDetailsEntity>, SupabaseFailure>(
        SupabaseResponse(data: group),
      );
    });

    final result = await repository.getGroupDetails('group-1');

    expect(
      result,
      const Success<GroupDetailsEntity, SupabaseFailure>(
        GroupDetailsEntity(
          name: '45',
          genres: [],
          participantCount: 0,
          city: '',
          stateCode: '',
        ),
      ),
    );
  });
}
