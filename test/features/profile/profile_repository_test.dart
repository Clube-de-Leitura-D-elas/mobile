import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late ProfileRepositoryImpl repository;

  final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x01]);

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = ProfileRepositoryImpl(supabaseService: mockSupabaseService);
  });

  group('setProfilePhoto', () {
    test('sends contentType and base64 encoded body', () async {
      when(
        () => mockSupabaseService.invokeFunction<String>(
          functionName: 'set-profile-photo',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder] as String Function(dynamic);
        return Success(
          SupabaseResponse(
            data: decoder({'photo_url': 'https://cdn.example/a.jpg'}),
          ),
        );
      });

      final result = await repository.setProfilePhoto(
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      expect(
        result,
        const Success<String, ProfileFailure>('https://cdn.example/a.jpg'),
      );

      final body =
          verify(
                () => mockSupabaseService.invokeFunction<String>(
                  functionName: 'set-profile-photo',
                  body: captureAny(named: 'body'),
                  decoder: any(named: 'decoder'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(body['contentType'], 'image/jpeg');
      expect(body['encoded'], base64Encode(bytes));
    });

    test('maps 413 to ProfilePhotoTooLargeFailure', () async {
      when(
        () => mockSupabaseService.invokeFunction<String>(
          functionName: 'set-profile-photo',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(message: 'large', code: '413'),
        ),
      );

      final result = await repository.setProfilePhoto(
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      expect(
        result,
        const Failure<String, ProfileFailure>(ProfilePhotoTooLargeFailure()),
      );
    });

    for (final code in ['400', '404', '422']) {
      test('maps $code to ProfilePhotoRejectedFailure', () async {
        when(
          () => mockSupabaseService.invokeFunction<String>(
            functionName: 'set-profile-photo',
            body: any(named: 'body'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async => Failure(
            FunctionSupabaseFailure(message: 'no', code: code),
          ),
        );

        final result = await repository.setProfilePhoto(
          bytes: bytes,
          contentType: 'image/jpeg',
        );

        expect(
          result,
          const Failure<String, ProfileFailure>(ProfilePhotoRejectedFailure()),
        );
      });
    }

    test('maps other errors to ProfilePhotoUploadFailure', () async {
      when(
        () => mockSupabaseService.invokeFunction<String>(
          functionName: 'set-profile-photo',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(message: 'boom', code: '500'),
        ),
      );

      final result = await repository.setProfilePhoto(
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      expect(
        result,
        const Failure<String, ProfileFailure>(ProfilePhotoUploadFailure()),
      );
    });

    test('returns upload failure when decoder yields null', () async {
      when(
        () => mockSupabaseService.invokeFunction<String>(
          functionName: 'set-profile-photo',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Success(SupabaseResponse<String>(data: null)),
      );

      final result = await repository.setProfilePhoto(
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      expect(
        result,
        const Failure<String, ProfileFailure>(ProfilePhotoUploadFailure()),
      );
    });
  });
}
