import 'package:bloc/bloc.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_photo_state.dart';

class EditProfilePhotoCubit extends Cubit<EditProfilePhotoState> {
  EditProfilePhotoCubit({
    required this.profileRepository,
    required this.photoPicker,
    String? initialPhotoUrl,
  }) : super(EditProfilePhotoState(photoUrl: initialPhotoUrl));

  final ProfileRepository profileRepository;
  final PhotoPicker photoPicker;

  bool _isPicking = false;

  Future<void> pickAndUpload() async {
    if (state.isUploading || _isPicking) return;

    if (state.notice != null) {
      emit(state.copyWith(clearNotice: true));
    }

    _isPicking = true;
    final pickResult = await photoPicker.pickFromGallery(limit: 1);
    _isPicking = false;
    if (isClosed) return;

    switch (pickResult) {
      case Failure(:final failure):
        emit(
          state.copyWith(notice: _pickerNotice(failure), clearNotice: false),
        );
      case Success(:final data):
        if (data.isEmpty) return;
        await _upload(data.first);
    }
  }

  Future<void> _upload(PickedPhoto photo) async {
    final contentType = photo.contentType;
    if (contentType == null) {
      emit(state.copyWith(notice: const EditProfilePhotoInvalidFormatNotice()));
      return;
    }

    emit(
      state.copyWith(
        status: EditProfilePhotoStatus.uploading,
        clearNotice: true,
      ),
    );

    final result = await profileRepository.setProfilePhoto(
      bytes: photo.bytes,
      contentType: contentType,
    );
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          state.copyWith(
            status: EditProfilePhotoStatus.idle,
            notice: _uploadNotice(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            photoUrl: data,
            status: EditProfilePhotoStatus.success,
            clearNotice: true,
          ),
        );
    }
  }

  EditProfilePhotoNotice _pickerNotice(
    PhotoPickerFailure failure,
  ) => switch (failure) {
    PhotoAccessDeniedFailure() => const EditProfilePhotoPickerDeniedNotice(),
    PhotoPickerUnknownFailure() => const EditProfilePhotoPickerFailedNotice(),
  };

  EditProfilePhotoNotice _uploadNotice(ProfileFailure failure) =>
      switch (failure) {
        ProfilePhotoTooLargeFailure() => const EditProfilePhotoTooLargeNotice(),
        ProfilePhotoRejectedFailure() => const EditProfilePhotoRejectedNotice(),
        ProfilePhotoUploadFailure() =>
          const EditProfilePhotoUploadFailedNotice(),
      };
}
