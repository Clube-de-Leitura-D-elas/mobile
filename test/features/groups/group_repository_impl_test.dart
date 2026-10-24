import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/data/models/group_event_history_model.dart';
import 'package:mobile/features/groups/data/models/group_model.dart';
import 'package:mobile/features/groups/data/models/next_event_model.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
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

  test('maps the authenticated participant groups response', () async {
    when(
      () => mockSupabaseService.invokeFunction<List<GroupModel>>(
        functionName: 'get-my-groups',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as List<GroupModel> Function(dynamic);
      return Success<SupabaseResponse<List<GroupModel>>, SupabaseFailure>(
        SupabaseResponse(
          data: decoder({
            'groups': [
              {
                'id': 'group-1',
                'name': 'Group 1',
                'participant_count': 2,
                'city_state': 'Porto Alegre, RS',
                'photo_url': null,
              },
            ],
          }),
        ),
      );
    });

    final result = await repository.getMyGroups();

    expect(
      result,
      const Success<List<GroupEntity>, GroupFailure>([
        GroupEntity(
          id: 'group-1',
          number: 1,
          participantsCount: 2,
          cityState: 'Porto Alegre, RS',
        ),
      ]),
    );
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

  test('maps event history items from the Edge Function response', () async {
    const eventHistoryJson = {
      'items': [
        {
          'id': 'meeting-1',
          'book_title': 'Quarto de Despejo',
          'book_cover_url': 'https://example.com/book-cover.jpg',
          'host_name': 'Ana Souza',
          'date': '2026-08-22T00:00:00Z',
        },
      ],
    };
    when(
      () => mockSupabaseService.invokeFunction<List<GroupEventHistoryModel>>(
        functionName: 'get-group-event-history?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as List<GroupEventHistoryModel> Function(dynamic);
      return Success<
        SupabaseResponse<List<GroupEventHistoryModel>>,
        SupabaseFailure
      >(SupabaseResponse(data: decoder(eventHistoryJson)));
    });

    final result = await repository.getEventHistory('group-1');

    expect(
      result,
      const Success<List<GroupMeeting>, GroupFailure>([
        GroupMeeting(
          id: 'meeting-1',
          bookTitle: 'Quarto de Despejo',
          bookCoverUrl: 'https://example.com/book-cover.jpg',
          hostName: 'Ana Souza',
          date: '2026-08-22T00:00:00Z',
          location: '',
        ),
      ]),
    );
  });

  test('maps an event history function failure to a group failure', () async {
    when(
      () => mockSupabaseService.invokeFunction<List<GroupEventHistoryModel>>(
        functionName: 'get-group-event-history?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer(
      (_) async =>
          const Failure(FunctionSupabaseFailure(message: 'Falha do servidor')),
    );

    final result = await repository.getEventHistory('group-1');

    expect(
      result,
      const Failure<List<GroupMeeting>, GroupFailure>(
        GroupEventHistoryFailure(),
      ),
    );
  });

  test('maps next event JSON to NextEventEntity', () async {
    // A edge function retorna { next_event: { ... } }
    const nextEventEnvelope = {
      'next_event': {
        'location_name': 'Porto Alegre, RS',
        'date': '2026-09-15T21:30:00Z',
        'host_name': 'Roberta',
      },
    };

    when(
      () => mockSupabaseService.invokeFunction<NextEventModel?>(
        functionName: 'get-group-next-event?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as NextEventModel? Function(dynamic);
      return Success<SupabaseResponse<NextEventModel?>, SupabaseFailure>(
        SupabaseResponse(data: decoder(nextEventEnvelope)),
      );
    });

    final result = await repository.getNextEvent('group-1');

    expect(
      result,
      Success<NextEventEntity?, GroupFailure>(
        NextEventEntity(
          location: 'Porto Alegre, RS',
          date: DateTime.utc(2026, 9, 15, 21, 30),
          hostName: 'Roberta',
        ),
      ),
    );
  });

  test('returns Success(null) when group has no next event', () async {
    // A edge function retorna { next_event: null } quando não há evento
    const noEventEnvelope = {'next_event': null};

    when(
      () => mockSupabaseService.invokeFunction<NextEventModel?>(
        functionName: 'get-group-next-event?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as NextEventModel? Function(dynamic);
      return Success<SupabaseResponse<NextEventModel?>, SupabaseFailure>(
        SupabaseResponse(data: decoder(noEventEnvelope)),
      );
    });

    final result = await repository.getNextEvent('group-1');

    expect(result, const Success<NextEventEntity?, GroupFailure>(null));
  });

  test('maps a next event function failure to GroupNextEventFailure', () async {
    when(
      () => mockSupabaseService.invokeFunction<NextEventModel?>(
        functionName: 'get-group-next-event?group_id=group-1',
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer(
      (_) async =>
          const Failure(FunctionSupabaseFailure(message: 'Falha do servidor')),
    );

    final result = await repository.getNextEvent('group-1');

    expect(
      result,
      const Failure<NextEventEntity?, GroupFailure>(GroupNextEventFailure()),
    );
  });

  group('setMeetingInvitationResponse', () {
    test('envia o status CONFIRMED corretamente e retorna Success', () async {
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: 'set-meeting-attendance-response',
          body: {'meeting_id': 'meeting-1', 'invitation_status': 'CONFIRMED'},
        ),
      ).thenAnswer(
        (_) async => const Success(SupabaseResponse<void>(data: null)),
      );

      final result = await repository.setMeetingInvitationResponse(
        'meeting-1',
        MeetingInvitationStatus.confirmed,
      );

      expect(result, const Success<void, GroupFailure>(null));
    });

    test('envia o status DECLINED corretamente e retorna Success', () async {
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: 'set-meeting-attendance-response',
          body: {'meeting_id': 'meeting-1', 'invitation_status': 'DECLINED'},
        ),
      ).thenAnswer(
        (_) async => const Success(SupabaseResponse<void>(data: null)),
      );

      final result = await repository.setMeetingInvitationResponse(
        'meeting-1',
        MeetingInvitationStatus.declined,
      );

      expect(result, const Success<void, GroupFailure>(null));
    });

    test('envia o status PENDING corretamente e retorna Success', () async {
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: 'set-meeting-attendance-response',
          body: {'meeting_id': 'meeting-1', 'invitation_status': 'PENDING'},
        ),
      ).thenAnswer(
        (_) async => const Success(SupabaseResponse<void>(data: null)),
      );

      final result = await repository.setMeetingInvitationResponse(
        'meeting-1',
        MeetingInvitationStatus.pending,
      );

      expect(result, const Success<void, GroupFailure>(null));
    });

    test('retorna GroupMeetingInvitationResponseFailure ao falhar', () async {
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: 'set-meeting-attendance-response',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const Failure(FunctionSupabaseFailure(message: 'Error')),
      );

      final result = await repository.setMeetingInvitationResponse(
        'meeting-1',
        MeetingInvitationStatus.confirmed,
      );

      expect(
        result,
        const Failure<void, GroupFailure>(
          GroupMeetingInvitationResponseFailure(),
        ),
      );
    });
  });
}
