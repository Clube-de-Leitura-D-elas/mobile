import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/profile_summary_model.dart';
import 'package:mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late MockProfileRemoteDataSource remoteDataSource;
  late ProfileRepositoryImpl repository;

  final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x01]);

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    remoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(
      supabaseService: mockSupabaseService,
      remoteDataSource: remoteDataSource,
    );
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

    final byKind = <SupabaseFailureKind, ProfileFailure>{
      SupabaseFailureKind.network: const ProfileNetworkFailure(),
      SupabaseFailureKind.unauthorized: const ProfileSessionExpiredFailure(),
    };
    for (final MapEntry(key: kind, value: expected) in byKind.entries) {
      test('maps $kind to ${expected.runtimeType}', () async {
        when(
          () => mockSupabaseService.invokeFunction<String>(
            functionName: 'set-profile-photo',
            body: any(named: 'body'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async => Failure(
            FunctionSupabaseFailure(message: 'raw', code: '0', kind: kind),
          ),
        );

        final result = await repository.setProfilePhoto(
          bytes: bytes,
          contentType: 'image/jpeg',
        );

        expect(result, Failure<String, ProfileFailure>(expected));
      });
    }

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
          (_) async =>
              Failure(FunctionSupabaseFailure(message: 'no', code: code)),
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

  group('getProfileSummary', () {
    void stubSummary(Result<ProfileSummaryModel?, SupabaseFailure> result) {
      when(
        () => remoteDataSource.getMyProfileSummary(),
      ).thenAnswer((_) async => result);
    }

    test('converte o model em entidade', () async {
      stubSummary(
        const Success(
          ProfileSummaryModel(
            booksReadCount: 5,
            groups: [ProfileGroupModel(id: 'g-1', number: 1)],
            reviewedBooks: [
              ProfileReviewedBookModel(
                bookId: 'b-1',
                title: 'Livro',
                rating: 4,
              ),
            ],
          ),
        ),
      );

      expect(
        await repository.getProfileSummary(),
        const Success<ProfileSummaryEntity, ProfileFailure>(
          ProfileSummaryEntity(
            booksReadCount: 5,
            groups: [ProfileGroupEntity(id: 'g-1', number: 1)],
            reviewedBooks: [
              ProfileReviewedBookEntity(
                bookId: 'b-1',
                title: 'Livro',
                rating: 4,
              ),
            ],
          ),
        ),
      );
    });

    test('resposta sem corpo vira falha de carregamento', () async {
      stubSummary(const Success(null));

      expect(
        await repository.getProfileSummary(),
        const Failure<ProfileSummaryEntity, ProfileFailure>(
          ProfileSummaryLoadFailure(),
        ),
      );
    });

    final cases = <SupabaseFailureKind, ProfileFailure>{
      SupabaseFailureKind.network: const ProfileNetworkFailure(),
      SupabaseFailureKind.unauthorized: const ProfileSessionExpiredFailure(),
      SupabaseFailureKind.server: const ProfileSummaryLoadFailure(),
      SupabaseFailureKind.notFound: const ProfileSummaryLoadFailure(),
    };
    for (final MapEntry(key: kind, value: expected) in cases.entries) {
      test('falha $kind vira ${expected.runtimeType}', () async {
        stubSummary(Failure(FunctionSupabaseFailure(message: 'x', kind: kind)));

        expect(
          await repository.getProfileSummary(),
          Failure<ProfileSummaryEntity, ProfileFailure>(expected),
        );
      });
    }
  });
}
