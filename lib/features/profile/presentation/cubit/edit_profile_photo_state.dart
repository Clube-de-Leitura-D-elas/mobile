import 'package:equatable/equatable.dart';

enum EditProfilePhotoStatus { idle, uploading, success }

sealed class EditProfilePhotoNotice extends Equatable {
  const EditProfilePhotoNotice();

  @override
  List<Object?> get props => [];
}

class EditProfilePhotoUploadFailedNotice extends EditProfilePhotoNotice {
  const EditProfilePhotoUploadFailedNotice();
}

class EditProfilePhotoRejectedNotice extends EditProfilePhotoNotice {
  const EditProfilePhotoRejectedNotice();
}

class EditProfilePhotoTooLargeNotice extends EditProfilePhotoNotice {
  const EditProfilePhotoTooLargeNotice();
}

class EditProfilePhotoPickerDeniedNotice extends EditProfilePhotoNotice {
  const EditProfilePhotoPickerDeniedNotice();
}

class EditProfilePhotoPickerFailedNotice extends EditProfilePhotoNotice {
  const EditProfilePhotoPickerFailedNotice();
}

class EditProfilePhotoInvalidFormatNotice extends EditProfilePhotoNotice {
  const EditProfilePhotoInvalidFormatNotice();
}

class EditProfilePhotoState extends Equatable {
  const EditProfilePhotoState({
    this.photoUrl,
    this.status = EditProfilePhotoStatus.idle,
    this.notice,
  });

  final String? photoUrl;
  final EditProfilePhotoStatus status;
  final EditProfilePhotoNotice? notice;

  bool get isUploading => status == EditProfilePhotoStatus.uploading;

  EditProfilePhotoState copyWith({
    String? photoUrl,
    EditProfilePhotoStatus? status,
    EditProfilePhotoNotice? notice,
    bool clearNotice = false,
  }) {
    return EditProfilePhotoState(
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }

  @override
  List<Object?> get props => [photoUrl, status, notice];
}
