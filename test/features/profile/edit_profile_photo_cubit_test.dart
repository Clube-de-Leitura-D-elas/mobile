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
        ).thenAnswer(
          (_) async => const Success('https://cdn.example/new.jpg'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(status: EditProfilePhotoStatus.uploading),
        const EditProfilePhotoState(photoUrl: 'https://cdn.example/new.jpg'),
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
        ).thenAnswer(
          (_) async => const Failure(ProfilePhotoRejectedFailure()),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.pickAndUpload(),
      expect: () => [
        const EditProfilePhotoState(status: EditProfilePhotoStatus.uploading),
        const EditProfilePhotoState(
          notice: EditProfilePhotoRejectedNotice(),
        ),
      ],
    );

    blocTest<EditProfilePhotoCubit, EditProfilePhotoState>(
      'emits picker denied notice when gallery access is denied',
      build: () {
        when(() => picker.pickFromGallery(limit: 1)).thenAnswer(
          (_) async => const Failure(PhotoAccessDeniedFailure()),
        );
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
  });
}
