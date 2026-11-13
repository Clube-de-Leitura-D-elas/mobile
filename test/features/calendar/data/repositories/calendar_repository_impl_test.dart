import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/calendar/data/models/calendar_meeting_model.dart';
import 'package:mobile/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

Map<String, dynamic> _meetingJson() => {
  'id': 'm1',
  'date': '2026-08-17T22:00:00+00:00',
  'local_date': '2026-08-17',
  'status': 'SCHEDULED',
  'location': null,
  'host_name': null,
  'group': {
    'id': 'g1',
    'number': 5,
    'city_state': 'Porto Alegre, RS',
    'photo_url': null,
    'participant_count': 27,
    'membership_status': null,
  },
};

void main() {
  late MockSupabaseService service;
  late CalendarRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    service = MockSupabaseService();
    repository = CalendarRepositoryImpl(supabaseService: service);
  });

  void stub(
    Result<SupabaseResponse<List<CalendarMeetingModel>>, SupabaseFailure>
    result,
  ) {
    when(
      () => service.invokeFunction<List<CalendarMeetingModel>>(
        functionName: any(named: 'functionName'),
        method: any(named: 'method'),
        queryParameters: any(named: 'queryParameters'),
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => result);
  }

  Future<Result<List<CalendarMeetingEntity>, CalendarFailure>> getAugust() =>
      repository.getMeetings(
        from: DateTime(2026, 7, 26),
        to: DateTime(2026, 9, 5),
      );

  test('GETs get-city-calendar with the civil from/to and decodes the '
      'meetings', () async {
    stub(const Success(SupabaseResponse(data: [])));

    final result = await getAugust();

    expect(result.unwrap(), isEmpty);
    final call = verify(
      () => service.invokeFunction<List<CalendarMeetingModel>>(
        functionName: 'get-city-calendar',
        method: HttpMethod.get,
        queryParameters: {'from': '2026-07-26', 'to': '2026-09-05'},
        decoder: captureAny(named: 'decoder'),
      ),
    )..called(1);

    final decoder =
        call.captured.single as List<CalendarMeetingModel> Function(dynamic);
    final decoded = decoder({
      'meetings': [_meetingJson()],
    });
    expect(decoded.single.id, 'm1');
  });

  test('returns the meetings as entities', () async {
    stub(
      Success(
        SupabaseResponse(data: [CalendarMeetingModel.fromJson(_meetingJson())]),
      ),
    );

    final result = await getAugust();

    final meetings = result.unwrap();
    expect(meetings, hasLength(1));
    expect(meetings.single.id, 'm1');
    expect(meetings.single.localDate, DateTime(2026, 8, 17));
  });

  test('returns CalendarLoadFailure when the body is empty', () async {
    stub(const Success(SupabaseResponse(data: null)));

    expect(
      await getAugust(),
      const Failure<List<CalendarMeetingEntity>, CalendarFailure>(
        CalendarLoadFailure(),
      ),
    );
  });

  final failures = <SupabaseFailureKind, CalendarFailure>{
    SupabaseFailureKind.network: const CalendarNetworkFailure(),
    SupabaseFailureKind.unauthorized: const CalendarSessionExpiredFailure(),
    SupabaseFailureKind.forbidden: const CalendarForbiddenFailure(),
    SupabaseFailureKind.notFound: const CalendarLoadFailure(),
    SupabaseFailureKind.validation: const CalendarLoadFailure(),
    SupabaseFailureKind.server: const CalendarLoadFailure(),
  };
  for (final MapEntry(key: kind, value: expected) in failures.entries) {
    test('maps a ${kind.name} failure to ${expected.runtimeType}', () async {
      stub(Failure(FunctionSupabaseFailure(message: 'boom', kind: kind)));

      expect(
        await getAugust(),
        Failure<List<CalendarMeetingEntity>, CalendarFailure>(expected),
      );
    });
  }
}
