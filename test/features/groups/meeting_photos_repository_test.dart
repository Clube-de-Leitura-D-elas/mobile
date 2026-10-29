import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/data/models/meeting_photos_model.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';
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

    void answerWith(Map<String, dynamic> json) {
      when(
        () => mockSupabaseService.invokeFunction<MeetingPhotosModel>(
          functionName: functionName,
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder]
                as MeetingPhotosModel Function(dynamic);
        return Success(SupabaseResponse(data: decoder(json)));
      });
    }

    test(
      'given the function returns photos, when loading, then maps them in order with the permission',
      () async {
        answerWith({
          'photos': [
            {'id': 'photo-1', 'url': 'https://a/1.jpg'},
            {'id': 'photo-2', 'url': 'https://a/2.jpg'},
          ],
          'can_add_photos': false,
        });

        final result = await repository.getMeetingPhotos('meeting-1');

        expect(
          result,
          const Success<MeetingPhotosEntity, GroupFailure>(
            MeetingPhotosEntity(
              photos: [
                MeetingPhotoEntity(id: 'photo-1', url: 'https://a/1.jpg'),
                MeetingPhotoEntity(id: 'photo-2', url: 'https://a/2.jpg'),
              ],
              canAddPhotos: false,
            ),
          ),
        );
      },
    );

    test(
      'given the function fails, when loading, then returns MeetingPhotosFailure',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<MeetingPhotosModel>(
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
          const Failure<MeetingPhotosEntity, GroupFailure>(
            MeetingPhotosFailure(),
          ),
        );
      },
    );

    test(
      'given a success without data, when loading, then returns MeetingPhotosFailure',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<MeetingPhotosModel>(
            functionName: functionName,
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((_) async => const Success(SupabaseResponse()));

        final result = await repository.getMeetingPhotos('meeting-1');

        expect(result, isA<Failure<MeetingPhotosEntity, GroupFailure>>());
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

  group('deleteMeetingPhoto', () {
    test(
      'given the function succeeds, when deleting, then sends the meeting and photo ids',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: 'delete-meeting-photo',
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => const Success(SupabaseResponse()));

        final result = await repository.deleteMeetingPhoto('meeting-1', 'p1');

        expect(result, const Success<void, GroupFailure>(null));
        verify(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: 'delete-meeting-photo',
            body: {'meeting_id': 'meeting-1', 'photo_id': 'p1'},
          ),
        ).called(1);
      },
    );

    test(
      'given the function fails, when deleting, then returns MeetingPhotoDeleteFailure',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: 'delete-meeting-photo',
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => const Failure(
            FunctionSupabaseFailure(message: 'Forbidden', code: '403'),
          ),
        );

        final result = await repository.deleteMeetingPhoto('meeting-1', 'p1');

        expect(
          result,
          const Failure<void, GroupFailure>(MeetingPhotoDeleteFailure()),
        );
      },
    );
  });

  group('updateMeetingPromoText', () {
    void answerWith(
      Result<SupabaseResponse<String?>, SupabaseFailure> Function(
        String? Function(dynamic) decoder,
      )
      build,
    ) {
      when(
        () => mockSupabaseService.invokeFunction<String?>(
          functionName: 'update-meeting-promo-text',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (invocation) async => build(
          invocation.namedArguments[#decoder] as String? Function(dynamic),
        ),
      );
    }

    test(
      'given the function saves the text, when updating, then returns the saved text',
      () async {
        answerWith(
          (decoder) => Success(
            SupabaseResponse(
              data: decoder({'meeting_id': 'meeting-1', 'promo_text': 'Oi'}),
            ),
          ),
        );

        final result = await repository.updateMeetingPromoText(
          'meeting-1',
          ' Oi ',
        );

        expect(result, const Success<String?, GroupFailure>('Oi'));
        verify(
          () => mockSupabaseService.invokeFunction<String?>(
            functionName: 'update-meeting-promo-text',
            body: {'meeting_id': 'meeting-1', 'promo_text': ' Oi '},
            decoder: any(named: 'decoder'),
          ),
        ).called(1);
      },
    );

    test(
      'given the function clears the text, when updating, then returns null',
      () async {
        answerWith(
          (decoder) => Success(
            SupabaseResponse(
              data: decoder({'meeting_id': 'meeting-1', 'promo_text': null}),
            ),
          ),
        );

        final result = await repository.updateMeetingPromoText('meeting-1', '');

        expect(result, const Success<String?, GroupFailure>(null));
      },
    );

    test(
      'given the function fails, when updating, then returns MeetingPromoTextUpdateFailure',
      () async {
        answerWith(
          (_) => const Failure(
            FunctionSupabaseFailure(message: 'Too long', code: '400'),
          ),
        );

        final result = await repository.updateMeetingPromoText(
          'meeting-1',
          'x',
        );

        expect(
          result,
          const Failure<String?, GroupFailure>(MeetingPromoTextUpdateFailure()),
        );
      },
    );
  });
}
