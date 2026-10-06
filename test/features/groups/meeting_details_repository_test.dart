import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/meeting_details_model.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late GroupRepositoryImpl repository;

  const functionName = 'get-meeting-details?meeting_id=meeting-1';

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = GroupRepositoryImpl(supabaseService: mockSupabaseService);
  });

  void answerWith(
    Result<SupabaseResponse<MeetingDetailsModel>, SupabaseFailure> result,
  ) {
    when(
      () => mockSupabaseService.invokeFunction<MeetingDetailsModel>(
        functionName: functionName,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => result);
  }

  test('maps the Edge Function response to MeetingDetailsEntity', () async {
    when(
      () => mockSupabaseService.invokeFunction<MeetingDetailsModel>(
        functionName: functionName,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as MeetingDetailsModel Function(dynamic);
      return Success(
        SupabaseResponse(
          data: decoder({
            'id': 'meeting-1',
            'number': 3,
            'date': null,
            'book_title': 'Dom Casmurro',
            'host_name': 'Beatriz Souza',
          }),
        ),
      );
    });

    final result = await repository.getMeetingDetails('meeting-1');

    expect(
      result,
      const Success<MeetingDetailsEntity, GroupFailure>(
        MeetingDetailsEntity(
          id: 'meeting-1',
          number: 3,
          bookTitle: 'Dom Casmurro',
          hostName: 'Beatriz Souza',
        ),
      ),
    );
  });

  test('maps a 404 to MeetingNotFoundFailure', () async {
    answerWith(const Failure(NotFoundSupabaseFailure(message: 'not found')));

    final result = await repository.getMeetingDetails('meeting-1');

    expect(
      result,
      const Failure<MeetingDetailsEntity, GroupFailure>(
        MeetingNotFoundFailure(),
      ),
    );
  });

  test('maps other failures to MeetingDetailsFailure', () async {
    answerWith(const Failure(FunctionSupabaseFailure(message: 'boom')));

    final result = await repository.getMeetingDetails('meeting-1');

    expect(
      result,
      const Failure<MeetingDetailsEntity, GroupFailure>(
        MeetingDetailsFailure(),
      ),
    );
  });

  test('maps an empty response to MeetingDetailsFailure', () async {
    answerWith(const Success(SupabaseResponse<MeetingDetailsModel>()));

    final result = await repository.getMeetingDetails('meeting-1');

    expect(
      result,
      const Failure<MeetingDetailsEntity, GroupFailure>(
        MeetingDetailsFailure(),
      ),
    );
  });
}
