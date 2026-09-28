import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
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
      () => mockSupabaseService.invokeFunction<GroupDetailsModel>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as GroupDetailsModel Function(dynamic);
      final group = decoder(groupJson);

      return Success<SupabaseResponse<GroupDetailsModel>, SupabaseFailure>(
        SupabaseResponse(data: group),
      );
    });

    final result = await repository.getGroupDetails('group-1');

    expect(
      result,
      const Success<GroupDetailsEntity, GroupFailure>(
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
      () => mockSupabaseService.invokeFunction<GroupDetailsModel>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).called(1);
  });

  test('maps an Edge Function failure to a group failure', () async {
    const failure = FunctionSupabaseFailure(message: 'Falha do servidor');
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsModel>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => const Failure(failure));

    final result = await repository.getGroupDetails('group-1');

    expect(
      result,
      const Failure<GroupDetailsEntity, GroupFailure>(GroupDetailsFailure()),
    );
  });

  test('uses empty location values when response fields are null', () async {
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsModel>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as GroupDetailsModel Function(dynamic);
      final group = decoder({
        'name': '45',
        'genres': <String>[],
        'participant_count': 0,
        'city': null,
        'state_code': null,
        'cover_image_url': null,
      });

      return Success<SupabaseResponse<GroupDetailsModel>, SupabaseFailure>(
        SupabaseResponse(data: group),
      );
    });

    final result = await repository.getGroupDetails('group-1');

    expect(
      result,
      const Success<GroupDetailsEntity, GroupFailure>(
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

  test('returns Failure when the function response has no data', () async {
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsModel>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer(
      (_) async =>
          const Success(SupabaseResponse<GroupDetailsModel>(data: null)),
    );

    final result = await repository.getGroupDetails('group-1');

    expect(result, isA<Failure<GroupDetailsEntity, GroupFailure>>());
  });

  test('maps a not found response to GroupNotFoundFailure', () async {
    when(
      () => mockSupabaseService.invokeFunction<GroupDetailsModel>(
        functionName: 'get-group-details?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer(
      (_) async => const Failure(
        FunctionSupabaseFailure(message: 'Not found', code: '404'),
      ),
    );

    final result = await repository.getGroupDetails('group-1');

    expect(
      result,
      const Failure<GroupDetailsEntity, GroupFailure>(GroupNotFoundFailure()),
    );
  });
}
