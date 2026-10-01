import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';

class MeetingPhotosCubit extends Cubit<MeetingPhotosState> {
  MeetingPhotosCubit({required this.groupRepository, required this.photoPicker})
    : super(const MeetingPhotosState());

  final GroupRepository groupRepository;
  final PhotoPicker photoPicker;

  String _meetingId = '';

  Future<void> load(String meetingId) async {
    _meetingId = meetingId;
    emit(state.copyWith(status: MeetingPhotosStatus.loading));

    final result = await groupRepository.getMeetingPhotos(meetingId);
    if (isClosed) return;

    switch (result) {
      case Failure():
        emit(state.copyWith(status: MeetingPhotosStatus.error));
      case Success(:final data):
        emit(state.copyWith(status: MeetingPhotosStatus.loaded, photos: data));
    }
  }

  Future<void> reload() => load(_meetingId);

  Future<void> pickAndUpload() async {
    if (state.isUploading) return;
    emit(state.copyWith(clearNotice: true));

    final remaining = MeetingPhotoLimits.perMeeting - state.photos.length;
    if (remaining <= 0) {
      emit(state.copyWith(notice: const MeetingPhotosLimitReachedNotice()));
      return;
    }

    final result = await photoPicker.pickFromGallery(
      limit: min(MeetingPhotoLimits.perSelection, remaining),
    );
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(state.copyWith(notice: _pickerNotice(failure)));
      case Success(:final data):
        await _uploadSelection(data);
    }
  }

  Future<void> retryFailed() async {
    if (state.isUploading || state.failedPhotos.isEmpty) return;
    emit(state.copyWith(clearNotice: true));
    await _upload(state.failedPhotos);
  }

  Future<void> _uploadSelection(List<PickedPhoto> selection) async {
    final accepted = selection.where(_isAccepted).toList(growable: false);
    final skipped = selection.length - accepted.length;
    if (skipped > 0) {
      emit(state.copyWith(notice: MeetingPhotosSkippedNotice(skipped)));
    }
    await _upload(accepted);
  }

  Future<void> _upload(List<PickedPhoto> queue) async {
    if (queue.isEmpty) return;
    final failed = <PickedPhoto>[];

    for (var index = 0; index < queue.length; index++) {
      emit(
        state.copyWith(
          progress: MeetingPhotosUploadProgress(
            current: index + 1,
            total: queue.length,
          ),
          failedPhotos: const [],
        ),
      );

      final photo = queue[index];
      final result = await groupRepository.addMeetingPhoto(
        _meetingId,
        photo.bytes,
        photo.contentType ?? '',
      );
      if (isClosed) return;

      switch (result) {
        case Success(:final data):
          emit(state.copyWith(photos: [...state.photos, data]));
        case Failure(failure: MeetingPhotoLimitFailure()):
          _finishUpload(
            failed,
            notice: const MeetingPhotosLimitReachedNotice(),
          );
          return;
        case Failure():
          failed.add(photo);
      }
    }

    _finishUpload(failed);
  }

  void _finishUpload(List<PickedPhoto> failed, {MeetingPhotosNotice? notice}) {
    emit(
      state.copyWith(
        clearProgress: true,
        failedPhotos: List.unmodifiable(failed),
        notice: notice,
      ),
    );
  }

  bool _isAccepted(PickedPhoto photo) =>
      MeetingPhotoLimits.contentTypes.contains(photo.contentType) &&
      photo.bytes.lengthInBytes <= MeetingPhotoLimits.maxBytes;

  MeetingPhotosNotice _pickerNotice(PhotoPickerFailure failure) =>
      switch (failure) {
        PhotoAccessDeniedFailure() => const MeetingPhotosAccessDeniedNotice(),
        PhotoPickerUnknownFailure() => const MeetingPhotosPickerFailedNotice(),
      };
}
