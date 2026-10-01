import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late GroupRepositoryImpl repository;

  final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x01]);

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = GroupRepositoryImpl(supabaseService: mockSupabaseService);
  });

  group('getMeetingPhotos', () {
    const functionName = 'get-meeting-photos?meeting_id=meeting-1';

    test(
      'given the function returns photos, when loading, then maps them in order',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<List<MeetingPhotoModel>>(
            functionName: functionName,
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((invocation) async {
          final decoder =
              invocation.namedArguments[#decoder]
                  as List<MeetingPhotoModel> Function(dynamic);
          return Success(
            SupabaseResponse(
              data: decoder({
                'photos': [
                  {'id': 'photo-1', 'url': 'https://a/1.jpg'},
                  {'id': 'photo-2', 'url': 'https://a/2.jpg'},
                ],
              }),
            ),
          );
        });

        final result = await repository.getMeetingPhotos('meeting-1');

        expect(
          result,
          const Success<List<MeetingPhotoEntity>, GroupFailure>([
            MeetingPhotoEntity(id: 'photo-1', url: 'https://a/1.jpg'),
            MeetingPhotoEntity(id: 'photo-2', url: 'https://a/2.jpg'),
          ]),
        );
      },
    );

    test(
      'given the function fails, when loading, then returns MeetingPhotosFailure',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<List<MeetingPhotoModel>>(
            functionName: functionName,
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async => const Failure(
            FunctionSupabaseFailure(message: 'Forbidden', code: '403'),
          ),
        );

        final result = await repository.getMeetingPhotos('meeting-1');

        expect(
          result,
          const Failure<List<MeetingPhotoEntity>, GroupFailure>(
            MeetingPhotosFailure(),
          ),
        );
      },
    );

    test(
      'given a success without data, when loading, then returns MeetingPhotosFailure',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<List<MeetingPhotoModel>>(
            functionName: functionName,
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((_) async => const Success(SupabaseResponse()));

        final result = await repository.getMeetingPhotos('meeting-1');

        expect(result, isA<Failure<List<MeetingPhotoEntity>, GroupFailure>>());
      },
    );
  });

  group('addMeetingPhoto', () {
    void answerUpload(
      Result<SupabaseResponse<MeetingPhotoModel>, SupabaseFailure> result,
    ) {
      when(
        () => mockSupabaseService.invokeFunction<MeetingPhotoModel>(
          functionName: 'add-meeting-photo',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    test(
      'given a photo, when uploading, then sends one JSON request with base64 data',
      () async {
        answerUpload(
          const Success(
            SupabaseResponse(
              data: MeetingPhotoModel(id: 'photo-1', url: 'https://a/1.jpg'),
              statusCode: 201,
            ),
          ),
        );

        final result = await repository.addMeetingPhoto(
          'meeting-1',
          'photo-1',
          bytes,
          'image/jpeg',
        );

        expect(
          result,
          const Success<MeetingPhotoEntity, GroupFailure>(
            MeetingPhotoEntity(id: 'photo-1', url: 'https://a/1.jpg'),
          ),
        );
        final body =
            verify(
                  () => mockSupabaseService.invokeFunction<MeetingPhotoModel>(
                    functionName: 'add-meeting-photo',
                    body: captureAny(named: 'body'),
                    decoder: any(named: 'decoder'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(body, {
          'meeting_id': 'meeting-1',
          'photo_id': 'photo-1',
          'content_type': 'image/jpeg',
          'data_base64': base64Encode(bytes),
        });
      },
    );

    test(
      'given the meeting is full (409), when uploading, then returns MeetingPhotoLimitFailure',
      () async {
        answerUpload(
          const Failure(FunctionSupabaseFailure(message: 'full', code: '409')),
        );

        final result = await repository.addMeetingPhoto(
          'meeting-1',
          'photo-1',
          bytes,
          'image/jpeg',
        );

        expect(
          result,
          const Failure<MeetingPhotoEntity, GroupFailure>(
            MeetingPhotoLimitFailure(),
          ),
        );
      },
    );

    for (final code in ['400', '403', '404', '413', '422']) {
      test(
        'given a $code, when uploading, then returns MeetingPhotoRejectedFailure',
        () async {
          answerUpload(
            Failure(FunctionSupabaseFailure(message: 'no', code: code)),
          );

          final result = await repository.addMeetingPhoto(
            'meeting-1',
            'photo-1',
            bytes,
            'image/jpeg',
          );

          expect(
            result,
            const Failure<MeetingPhotoEntity, GroupFailure>(
              MeetingPhotoRejectedFailure(),
            ),
          );
        },
      );
    }

    test(
      'given any other error, when uploading, then returns MeetingPhotoUploadFailure',
      () async {
        answerUpload(
          const Failure(FunctionSupabaseFailure(message: 'boom', code: '500')),
        );

        final result = await repository.addMeetingPhoto(
          'meeting-1',
          'photo-1',
          bytes,
          'image/jpeg',
        );

        expect(
          result,
          const Failure<MeetingPhotoEntity, GroupFailure>(
            MeetingPhotoUploadFailure(),
          ),
        );
      },
    );
  });
}
