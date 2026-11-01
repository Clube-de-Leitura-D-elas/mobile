import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_photo_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_photo_state.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

PickedPhoto _photo({String? contentType = 'image/jpeg'}) => PickedPhoto(
  id: 'pick-1',
  bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x01]),
  contentType: contentType,
);

void main() {
  late MockProfileRepository repository;
  late MockPhotoPicker picker;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repository = MockProfileRepository();
    picker = MockPhotoPicker();
  });

  EditProfilePhotoCubit buildCubit({String? initialPhotoUrl}) =>
      EditProfilePhotoCubit(
        profileRepository: repository,
        photoPicker: picker,
        initialPhotoUrl: initialPhotoUrl,
      );

  group('pickAndUpload', () {
    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'uploads picked photo and updates photoUrl on success',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => Success([_photo()]));
        when(
          () => repository.setProfilePhoto(
            bytes: any(named: 'bytes'),
            contentType: 'image/jpeg',
          ),
        ).thenAnswer((_) async => const Success('https://cdn.example/new.jpg'));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(status: EditProfilePhotoStatus.uploading),
        const EditProfilePhotoState(
          photoUrl: 'https://cdn.example/new.jpg',
          status: EditProfilePhotoStatus.success,
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits rejected notice when upload is rejected',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => Success([_photo()]));
        when(
          () => repository.setProfilePhoto(
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          ),
        ).thenAnswer((_) async => const Failure(ProfilePhotoRejectedFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(status: EditProfilePhotoStatus.uploading),
        const EditProfilePhotoState(notice: EditProfilePhotoRejectedNotice()),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits picker denied notice when gallery access is denied',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => const Failure(PhotoAccessDeniedFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(
          notice: EditProfilePhotoPickerDeniedNotice(),
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits invalid format notice when content type is missing',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => Success([_photo(contentType: null)]));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(
          notice: EditProfilePhotoInvalidFormatNotice(),
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'clears the previous notice before opening the gallery again',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => const Success([]));
        return buildCubit();
      },
      seed: () => const EditProfilePhotoState(
        notice: EditProfilePhotoUploadFailedNotice(),
      ),
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [const EditProfilePhotoState()],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'ignores an empty gallery selection',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => const Success([]));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => <EditProfilePhotoState>[],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits picker failed notice when the gallery fails',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => const Failure(PhotoPickerUnknownFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(
          notice: EditProfilePhotoPickerFailedNotice(),
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits success when the returned url does not change',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => Success([_photo()]));
        when(
          () => repository.setProfilePhoto(
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          ),
        ).thenAnswer(
          (_) async => const Success('https://cdn.example/same.jpg'),
        );
        return buildCubit(initialPhotoUrl: 'https://cdn.example/same.jpg');
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(
          photoUrl: 'https://cdn.example/same.jpg',
          status: EditProfilePhotoStatus.uploading,
        ),
        const EditProfilePhotoState(
          photoUrl: 'https://cdn.example/same.jpg',
          status: EditProfilePhotoStatus.success,
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits an upload failed notice',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => Success([_photo()]));
        when(
          () => repository.setProfilePhoto(
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          ),
        ).thenAnswer((_) async => const Failure(ProfilePhotoUploadFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(status: EditProfilePhotoStatus.uploading),
        const EditProfilePhotoState(
          notice: EditProfilePhotoUploadFailedNotice(),
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits a too large notice and keeps the current photo',
      build: () {
        when(
          () => picker.pickFromGallery(limit: 1),
        ).thenAnswer((_) async => Success([_photo()]));
        when(
          () => repository.setProfilePhoto(
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          ),
        ).thenAnswer((_) async => const Failure(ProfilePhotoTooLargeFailure()));
        return buildCubit(initialPhotoUrl: 'https://cdn.example/old.jpg');
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(
          photoUrl: 'https://cdn.example/old.jpg',
          status: EditProfilePhotoStatus.uploading,
        ),
        const EditProfilePhotoState(
          photoUrl: 'https://cdn.example/old.jpg',
          notice: EditProfilePhotoTooLargeNotice(),
        ),
      ],
    );

    test('ignores a second pick while the gallery is open', () async {
      final cubit = buildCubit();
      final started = Completer<void>();
      final release = Completer<void>();
      when(() => picker.pickFromGallery(limit: 1)).thenAnswer((_) async {
        started.complete();
        await release.future;
        return const Success(<PickedPhoto>[]);
      });

      final first = cubit.pickAndUpload();
      await started.future;
      await cubit.pickAndUpload();
      release.complete();
      await first;

      expect(cubit.state.notice, isNull);
      await cubit.close();
    });

    test('stops when the cubit closes during the gallery pick', () async {
      final cubit = buildCubit();
      when(() => picker.pickFromGallery(limit: 1)).thenAnswer((_) async {
        await cubit.close();
        return Success([_photo()]);
      });

      await cubit.pickAndUpload();

      verify(() => picker.pickFromGallery(limit: 1)).called(1);
      verifyNever(
        () => repository.setProfilePhoto(
          bytes: any(named: 'bytes'),
          contentType: any(named: 'contentType'),
        ),
      );
      expect(cubit.isClosed, isTrue);
      expect(cubit.state, const EditProfilePhotoState());
    });

    test('stops when the cubit closes during the upload', () async {
      final cubit = buildCubit();
      when(
        () => picker.pickFromGallery(limit: 1),
      ).thenAnswer((_) async => Success([_photo()]));
      when(
        () => repository.setProfilePhoto(
          bytes: any(named: 'bytes'),
          contentType: any(named: 'contentType'),
        ),
      ).thenAnswer((_) async {
        await cubit.close();
        return const Failure(ProfilePhotoUploadFailure());
      });

      await cubit.pickAndUpload();

      verify(() => picker.pickFromGallery(limit: 1)).called(1);
      verify(
        () => repository.setProfilePhoto(
          bytes: any(named: 'bytes'),
          contentType: 'image/jpeg',
        ),
      ).called(1);
      expect(cubit.isClosed, isTrue);
      expect(cubit.state.status, EditProfilePhotoStatus.uploading);
    });
  });

  test('failures and notices compare by type', () {
    expect(
      const ProfilePhotoUploadFailure(),
      const ProfilePhotoUploadFailure(),
    );
    expect(
      const ProfilePhotoRejectedFailure(),
      isNot(const ProfilePhotoTooLargeFailure()),
    );
    expect(const ProfilePhotoUploadFailure().props, isEmpty);
    expect(
      const EditProfilePhotoUploadFailedNotice(),
      const EditProfilePhotoUploadFailedNotice(),
    );
    expect(const EditProfilePhotoRejectedNotice().props, isEmpty);
    expect(const EditProfilePhotoTooLargeNotice().props, isEmpty);
    expect(const EditProfilePhotoPickerDeniedNotice().props, isEmpty);
    expect(const EditProfilePhotoPickerFailedNotice().props, isEmpty);
    expect(const EditProfilePhotoInvalidFormatNotice().props, isEmpty);

    const state = EditProfilePhotoState(
      photoUrl: 'https://cdn.example/a.jpg',
      notice: EditProfilePhotoRejectedNotice(),
    );
    expect(state.copyWith().photoUrl, 'https://cdn.example/a.jpg');
    expect(state.copyWith(clearNotice: true).notice, isNull);
  });
}
