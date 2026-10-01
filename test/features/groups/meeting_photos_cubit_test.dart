import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

PickedPhoto _picked(int seed, {String? contentType = 'image/jpeg'}) =>
    PickedPhoto(
      id: 'photo-$seed',
      bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, seed]),
      contentType: contentType,
    );

MeetingPhotoEntity _photo(String id) =>
    MeetingPhotoEntity(id: id, url: 'https://a/$id.jpg');

MeetingPhotosUploadProgress _progress(int current, int total) =>
    MeetingPhotosUploadProgress(current: current, total: total);

void main() {
  late MockGroupRepository repository;
  late MockPhotoPicker picker;

  const meetingId = 'meeting-1';
  final existing = _photo('existing');
  final loaded = MeetingPhotosState(
    status: MeetingPhotosStatus.loaded,
    photos: [existing],
  );

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repository = MockGroupRepository();
    picker = MockPhotoPicker();
    when(
      () => repository.getMeetingPhotos(meetingId),
    ).thenAnswer((_) async => Success([existing]));
  });

  MeetingPhotosCubit buildLoadedCubit() =>
      MeetingPhotosCubit(groupRepository: repository, photoPicker: picker)
        ..load(meetingId);

  void givenPicked(List<PickedPhoto> photos) {
    when(
      () => picker.pickFromGallery(limit: any(named: 'limit')),
    ).thenAnswer((_) async => Success(photos));
  }

  void givenUpload(
    PickedPhoto photo,
    Result<MeetingPhotoEntity, GroupFailure> result,
  ) {
    when(
      () => repository.addMeetingPhoto(
        meetingId,
        photo.id,
        photo.bytes,
        'image/jpeg',
      ),
    ).thenAnswer((_) async => result);
  }

  group('load', () {
    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given photos exist, when loading, then emits loaded with the photos',
      build: () =>
          MeetingPhotosCubit(groupRepository: repository, photoPicker: picker),
      act: (cubit) => cubit.load(meetingId),
      expect: () => [const MeetingPhotosState(), loaded],
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given the request fails, when loading, then emits error',
      build: () {
        when(
          () => repository.getMeetingPhotos(meetingId),
        ).thenAnswer((_) async => const Failure(MeetingPhotosFailure()));
        return MeetingPhotosCubit(
          groupRepository: repository,
          photoPicker: picker,
        );
      },
      act: (cubit) => cubit.load(meetingId),
      expect: () => [
        const MeetingPhotosState(),
        const MeetingPhotosState(status: MeetingPhotosStatus.error),
      ],
    );
  });

  group('pickAndUpload', () {
    final first = _picked(1);
    final second = _picked(2);

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given two photos are picked, when uploading, then emits progress for each and appends them',
      build: () {
        givenPicked([first, second]);
        givenUpload(first, Success(_photo('a')));
        givenUpload(second, Success(_photo('b')));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => [
        loaded.copyWith(progress: _progress(1, 2)),
        loaded.copyWith(
          progress: _progress(1, 2),
          photos: [existing, _photo('a')],
        ),
        loaded.copyWith(
          progress: _progress(2, 2),
          photos: [existing, _photo('a')],
        ),
        loaded.copyWith(
          progress: _progress(2, 2),
          photos: [existing, _photo('a'), _photo('b')],
        ),
        loaded.copyWith(photos: [existing, _photo('a'), _photo('b')]),
      ],
      verify: (_) {
        verify(() => picker.pickFromGallery(limit: 10)).called(1);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given one upload fails, when retrying, then sends only the failed photo',
      build: () {
        final third = _picked(3);
        givenPicked([first, second, third]);
        givenUpload(first, Success(_photo('a')));
        givenUpload(third, Success(_photo('c')));
        var attempts = 0;
        when(
          () => repository.addMeetingPhoto(
            meetingId,
            second.id,
            second.bytes,
            'image/jpeg',
          ),
        ).thenAnswer(
          (_) async => attempts++ == 0
              ? const Failure(MeetingPhotoUploadFailure())
              : Success(_photo('b')),
        );
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
        expect(cubit.state.failedPhotos, [second]);
        expect(cubit.state.isUploading, isFalse);
        expect(cubit.state.photos.map((photo) => photo.id), [
          'existing',
          'a',
          'c',
        ]);
        await cubit.retryFailed();
      },
      verify: (cubit) {
        expect(cubit.state.failedPhotos, isEmpty);
        expect(cubit.state.photos.map((photo) => photo.id), [
          'existing',
          'a',
          'c',
          'b',
        ]);
        verify(
          () => repository.addMeetingPhoto(
            meetingId,
            first.id,
            first.bytes,
            any(),
          ),
        ).called(1);
        verify(
          () => repository.addMeetingPhoto(
            meetingId,
            second.id,
            second.bytes,
            any(),
          ),
        ).called(2);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given a retry of one photo, when retrying, then progress counts only the failed ones',
      build: () {
        givenPicked([first, second]);
        givenUpload(first, const Failure(MeetingPhotoUploadFailure()));
        givenUpload(second, Success(_photo('b')));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
        givenUpload(first, Success(_photo('a')));
        await cubit.retryFailed();
      },
      skip: 5,
      expect: () => [
        loaded.copyWith(
          progress: _progress(1, 1),
          photos: [existing, _photo('b')],
          failedPhotos: const [],
        ),
        loaded.copyWith(
          progress: _progress(1, 1),
          photos: [existing, _photo('b'), _photo('a')],
        ),
        loaded.copyWith(photos: [existing, _photo('b'), _photo('a')]),
      ],
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given photo access is denied, when picking, then emits the denied notice',
      build: () {
        when(
          () => picker.pickFromGallery(limit: any(named: 'limit')),
        ).thenAnswer((_) async => const Failure(PhotoAccessDeniedFailure()));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => [
        loaded.copyWith(notice: const MeetingPhotosAccessDeniedNotice()),
      ],
      verify: (_) {
        verifyNever(
          () => repository.addMeetingPhoto(any(), any(), any(), any()),
        );
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given access was denied before, when denied again, then the notice is emitted again',
      build: () {
        when(
          () => picker.pickFromGallery(limit: any(named: 'limit')),
        ).thenAnswer((_) async => const Failure(PhotoAccessDeniedFailure()));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => [
        loaded.copyWith(notice: const MeetingPhotosAccessDeniedNotice()),
        loaded,
        loaded.copyWith(notice: const MeetingPhotosAccessDeniedNotice()),
      ],
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given the selection is cancelled, when picking, then nothing changes',
      build: () {
        givenPicked(const []);
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => const <MeetingPhotosState>[],
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given an oversize and an unsupported photo, when picking, then skips them and uploads the rest',
      build: () {
        final oversize = PickedPhoto(
          id: 'oversize',
          bytes: Uint8List(MeetingPhotoLimits.maxBytes + 1),
          contentType: 'image/jpeg',
        );
        givenPicked([oversize, _picked(9, contentType: null), first]);
        givenUpload(first, Success(_photo('a')));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => [
        loaded.copyWith(notice: const MeetingPhotosSkippedNotice(2)),
        loaded.copyWith(
          notice: const MeetingPhotosSkippedNotice(2),
          progress: _progress(1, 1),
        ),
        loaded.copyWith(
          notice: const MeetingPhotosSkippedNotice(2),
          progress: _progress(1, 1),
          photos: [existing, _photo('a')],
        ),
        loaded.copyWith(
          notice: const MeetingPhotosSkippedNotice(2),
          photos: [existing, _photo('a')],
        ),
      ],
      verify: (_) {
        verify(
          () => repository.addMeetingPhoto(any(), any(), any(), any()),
        ).called(1);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given 45 photos, when picking, then limits the selection to the remaining 5',
      build: () {
        when(() => repository.getMeetingPhotos(meetingId)).thenAnswer(
          (_) async => Success(List.generate(45, (i) => _photo('p$i'))),
        );
        givenPicked(const []);
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      verify: (_) {
        verify(() => picker.pickFromGallery(limit: 5)).called(1);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given the meeting is full, when picking, then emits the limit notice without opening the gallery',
      build: () {
        when(() => repository.getMeetingPhotos(meetingId)).thenAnswer(
          (_) async => Success(List.generate(50, (i) => _photo('p$i'))),
        );
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => [
        isA<MeetingPhotosState>().having(
          (state) => state.notice,
          'notice',
          const MeetingPhotosLimitReachedNotice(),
        ),
      ],
      verify: (_) {
        verifyNever(() => picker.pickFromGallery(limit: any(named: 'limit')));
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given the server rejects for the limit, when uploading, then stops and emits the limit notice',
      build: () {
        givenPicked([first, second]);
        givenUpload(first, const Failure(MeetingPhotoLimitFailure()));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      skip: 1,
      expect: () => [
        loaded.copyWith(progress: _progress(1, 2)),
        loaded.copyWith(notice: const MeetingPhotosLimitReachedNotice()),
      ],
      verify: (_) {
        verifyNever(
          () => repository.addMeetingPhoto(
            meetingId,
            second.id,
            second.bytes,
            any(),
          ),
        );
      },
    );
    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given a pending failure, when a new selection is uploaded, then the pending failure is kept for retry',
      build: () {
        givenUpload(first, const Failure(MeetingPhotoUploadFailure()));
        givenUpload(second, Success(_photo('b')));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        givenPicked([first]);
        await cubit.pickAndUpload();
        givenPicked([second]);
        await cubit.pickAndUpload();
      },
      verify: (cubit) {
        expect(cubit.state.failedPhotos, [first]);
        expect(cubit.state.photos.map((photo) => photo.id), ['existing', 'b']);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given the gallery is already open, when tapping again, then does not open a second picker',
      build: () {
        final selection =
            Completer<Result<List<PickedPhoto>, PhotoPickerFailure>>();
        when(
          () => picker.pickFromGallery(limit: any(named: 'limit')),
        ).thenAnswer((_) => selection.future);
        addTearDown(() => selection.complete(const Success([])));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        unawaited(cubit.pickAndUpload());
        await cubit.pickAndUpload();
      },
      verify: (_) {
        verify(
          () => picker.pickFromGallery(limit: any(named: 'limit')),
        ).called(1);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given an earlier failure in the batch, when the server rejects for the limit, then nothing is left to retry',
      build: () {
        givenPicked([first, second]);
        givenUpload(first, const Failure(MeetingPhotoUploadFailure()));
        givenUpload(second, const Failure(MeetingPhotoLimitFailure()));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      verify: (cubit) {
        expect(cubit.state.failedPhotos, isEmpty);
        expect(cubit.state.isUploading, isFalse);
        expect(cubit.state.notice, const MeetingPhotosLimitReachedNotice());
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given the server rejects a photo, when uploading, then it is not offered for retry and a notice is shown',
      build: () {
        givenPicked([first, second]);
        givenUpload(first, const Failure(MeetingPhotoRejectedFailure()));
        givenUpload(second, Success(_photo('b')));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
      },
      verify: (cubit) {
        expect(cubit.state.failedPhotos, isEmpty);
        expect(cubit.state.notice, const MeetingPhotosRejectedNotice(1));
        expect(cubit.state.photos.map((photo) => photo.id), ['existing', 'b']);
      },
    );

    blocTest<MeetingPhotosCubit, MeetingPhotosState>(
      'given a failed photo, when retrying, then resends it with the same photo id',
      build: () {
        givenPicked([first]);
        givenUpload(first, const Failure(MeetingPhotoUploadFailure()));
        return buildLoadedCubit();
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.pickAndUpload();
        await cubit.retryFailed();
      },
      verify: (_) {
        verify(
          () => repository.addMeetingPhoto(
            meetingId,
            'photo-1',
            first.bytes,
            'image/jpeg',
          ),
        ).called(2);
      },
    );
  });
}
