import 'package:equatable/equatable.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';

enum MeetingPhotosStatus { loading, loaded, error }

class MeetingPhotosUploadProgress extends Equatable {
  const MeetingPhotosUploadProgress({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  List<Object?> get props => [current, total];
}

sealed class MeetingPhotosNotice extends Equatable {
  const MeetingPhotosNotice();

  @override
  List<Object?> get props => [];
}

class MeetingPhotosAccessDeniedNotice extends MeetingPhotosNotice {
  const MeetingPhotosAccessDeniedNotice();
}

class MeetingPhotosPickerFailedNotice extends MeetingPhotosNotice {
  const MeetingPhotosPickerFailedNotice();
}

class MeetingPhotosSkippedNotice extends MeetingPhotosNotice {
  const MeetingPhotosSkippedNotice(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

class MeetingPhotosLimitReachedNotice extends MeetingPhotosNotice {
  const MeetingPhotosLimitReachedNotice();
}

class MeetingPhotosRejectedNotice extends MeetingPhotosNotice {
  const MeetingPhotosRejectedNotice(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

class MeetingPhotoDeletedNotice extends MeetingPhotosNotice {
  const MeetingPhotoDeletedNotice();
}

class MeetingPhotoDeleteFailedNotice extends MeetingPhotosNotice {
  const MeetingPhotoDeleteFailedNotice();
}

class MeetingPromoTextSavedNotice extends MeetingPhotosNotice {
  const MeetingPromoTextSavedNotice();
}

class MeetingPromoTextSaveFailedNotice extends MeetingPhotosNotice {
  const MeetingPromoTextSaveFailedNotice();
}

class MeetingPhotosState extends Equatable {
  const MeetingPhotosState({
    this.status = MeetingPhotosStatus.loading,
    this.photos = const [],
    this.progress,
    this.failedPhotos = const [],
    this.notice,
    this.canAddPhotos = true,
    this.promoText,
    this.isSavingPromoText = false,
  });

  final MeetingPhotosStatus status;
  final List<MeetingPhotoEntity> photos;
  final MeetingPhotosUploadProgress? progress;
  final List<PickedPhoto> failedPhotos;
  final MeetingPhotosNotice? notice;

  /// Coordenadora do grupo ou anfitriã do encontro. Controla se o botão de
  /// adicionar foto aparece; o envio é validado de novo no backend.
  final bool canAddPhotos;

  final String? promoText;
  final bool isSavingPromoText;

  bool get isUploading => progress != null;

  MeetingPhotosState copyWith({
    MeetingPhotosStatus? status,
    List<MeetingPhotoEntity>? photos,
    MeetingPhotosUploadProgress? progress,
    bool clearProgress = false,
    List<PickedPhoto>? failedPhotos,
    MeetingPhotosNotice? notice,
    bool clearNotice = false,
    bool? canAddPhotos,
    String? promoText,
    bool clearPromoText = false,
    bool? isSavingPromoText,
  }) {
    return MeetingPhotosState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      progress: clearProgress ? null : progress ?? this.progress,
      failedPhotos: failedPhotos ?? this.failedPhotos,
      notice: clearNotice ? null : notice ?? this.notice,
      canAddPhotos: canAddPhotos ?? this.canAddPhotos,
      promoText: clearPromoText ? null : promoText ?? this.promoText,
      isSavingPromoText: isSavingPromoText ?? this.isSavingPromoText,
    );
  }

  @override
  List<Object?> get props => [
    status,
    photos,
    progress,
    failedPhotos,
    notice,
    canAddPhotos,
    promoText,
    isSavingPromoText,
  ];
}
