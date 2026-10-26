import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/place_suggestion_model.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService supabase;
  late GroupRepositoryImpl repository;

  setUp(() {
    supabase = MockSupabaseService();
    repository = GroupRepositoryImpl(supabaseService: supabase);
  });

  group('searchPlaces', () {
    // "café paris" com acento e espaço, já codificado para a URL.
    const functionName = 'search-places?query=caf%C3%A9+paris';

    test(
      'given the function returns places, when searching, then maps them',
      () async {
        when(
          () => supabase.invokeFunction<List<PlaceSuggestionModel>>(
            functionName: functionName,
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((invocation) async {
          final decoder =
              invocation.namedArguments[#decoder]
                  as List<PlaceSuggestionModel> Function(dynamic);
          return Success(
            SupabaseResponse(
              data: decoder({
                'places': [
                  {
                    'google_place_id': 'place-1',
                    'name': 'Café Paris',
                    'address': 'R. A, 10',
                  },
                ],
              }),
            ),
          );
        });

        final result = await repository.searchPlaces('café paris');

        expect(
          result,
          const Success<List<PlaceSuggestionEntity>, GroupFailure>([
            PlaceSuggestionEntity(
              googlePlaceId: 'place-1',
              name: 'Café Paris',
              address: 'R. A, 10',
            ),
          ]),
        );
      },
    );

    test(
      'given the function fails, when searching, then returns PlaceSearchFailure',
      () async {
        when(
          () => supabase.invokeFunction<List<PlaceSuggestionModel>>(
            functionName: functionName,
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async => const Failure(
            FunctionSupabaseFailure(message: 'bad gateway', code: '502'),
          ),
        );

        final result = await repository.searchPlaces('café paris');

        expect(
          result,
          const Failure<List<PlaceSuggestionEntity>, GroupFailure>(
            PlaceSearchFailure(),
          ),
        );
      },
    );
  });

  group('updateMeeting', () {
    final date = DateTime(2026, 10, 30, 19, 30);

    void answerWith(Result<SupabaseResponse<void>, SupabaseFailure> result) {
      when(
        () => supabase.invokeFunction<void>(
          functionName: 'update-meeting',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => result);
    }

    Map<String, dynamic> sentBody() {
      return verify(
            () => supabase.invokeFunction<void>(
              functionName: 'update-meeting',
              body: captureAny(named: 'body'),
            ),
          ).captured.single
          as Map<String, dynamic>;
    }

    test(
      'given a new place, when saving, then sends the date in UTC and the place id',
      () async {
        answerWith(const Success(SupabaseResponse()));

        final result = await repository.updateMeeting(
          meetingId: 'meeting-1',
          date: date,
          googlePlaceId: 'place-1',
          description: 'Trazer o livro',
        );

        expect(result, const Success<void, GroupFailure>(null));
        expect(sentBody(), {
          'meeting_id': 'meeting-1',
          'date': date.toUtc().toIso8601String(),
          'google_place_id': 'place-1',
          'description': 'Trazer o livro',
        });
      },
    );

    test(
      'given no new place, when saving, then does not send google_place_id',
      () async {
        answerWith(const Success(SupabaseResponse()));

        await repository.updateMeeting(meetingId: 'meeting-1', date: date);

        final body = sentBody();
        expect(body.containsKey('google_place_id'), isFalse);
        expect(body['description'], isNull);
      },
    );

    test(
      'given the meeting can no longer be edited, when saving, then returns MeetingNotEditableFailure',
      () async {
        answerWith(
          const Failure(
            FunctionSupabaseFailure(message: 'locked', code: '409'),
          ),
        );

        final result = await repository.updateMeeting(
          meetingId: 'meeting-1',
          date: date,
        );

        expect(
          result,
          const Failure<void, GroupFailure>(MeetingNotEditableFailure()),
        );
      },
    );

    test(
      'given an unexpected error, when saving, then returns MeetingUpdateFailure',
      () async {
        answerWith(
          const Failure(FunctionSupabaseFailure(message: 'boom', code: '500')),
        );

        final result = await repository.updateMeeting(
          meetingId: 'meeting-1',
          date: date,
        );

        expect(
          result,
          const Failure<void, GroupFailure>(MeetingUpdateFailure()),
        );
      },
    );
  });
}
