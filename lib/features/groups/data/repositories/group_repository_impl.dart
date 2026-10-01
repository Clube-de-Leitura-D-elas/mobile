import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/data/models/group_event_history_model.dart';
import 'package:mobile/features/groups/data/models/meeting_details_model.dart';
import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/data/models/group_model.dart';
import 'package:mobile/features/groups/data/models/next_event_model.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseService supabaseService;

  const GroupRepositoryImpl({required this.supabaseService});

  @override
  Future<Result<List<GroupEntity>, GroupFailure>> getMyGroups() async {
    final result = await supabaseService.invokeFunction<List<GroupModel>>(
      functionName: 'get-my-groups',
      decoder: GroupModel.listFromJson,
    );

    switch (result) {
      case Failure():
        return const Failure(GroupListFailure());
      case Success(:final data):
        final groups = data.data;
        if (groups == null) {
          return const Failure(GroupListFailure());
        }
        return Success(groups.map((group) => group.toDomain()).toList());
    }
  }

  @override
  Future<Result<GroupDetailsEntity, GroupFailure>> getGroupDetails(
    String groupId,
  ) async {
    final result = await supabaseService.invokeFunction<GroupDetailsModel>(
      functionName: 'get-group-details?group_id=$groupId',
      decoder: GroupDetailsModel.fromJson,
    );

    switch (result) {
      case Failure(:final failure):
        if (failure is NotFoundSupabaseFailure || failure.code == '404') {
          return const Failure(GroupNotFoundFailure());
        }
        return const Failure(GroupDetailsFailure());
      case Success(:final data):
        final group = data.data;
        if (group == null) {
          return const Failure(GroupDetailsFailure());
        }
        return Success<GroupDetailsEntity, GroupFailure>(group.toDomain());
    }
  }

  @override
  Future<Result<List<GroupMeeting>, GroupFailure>> getEventHistory(
    String groupId,
  ) async {
    final result = await supabaseService
        .invokeFunction<List<GroupEventHistoryModel>>(
          functionName: 'get-group-event-history?group_id=$groupId',
          decoder: GroupEventHistoryModel.listFromJson,
        );

    switch (result) {
      case Failure():
        return const Failure(GroupEventHistoryFailure());
      case Success(:final data):
        final meetings = data.data;
        if (meetings == null) {
          return const Failure(GroupEventHistoryFailure());
        }
        return Success<List<GroupMeeting>, GroupFailure>(
          meetings.map((meeting) => meeting.toDomain()).toList(growable: false),
        );
    }
  }

  @override
  Future<Result<MeetingDetailsEntity, GroupFailure>> getMeetingDetails(
    String meetingId,
  ) async {
    final result = await supabaseService.invokeFunction<MeetingDetailsModel>(
      functionName: 'get-meeting-details?meeting_id=$meetingId',
      decoder: MeetingDetailsModel.fromJson,
    );

    switch (result) {
      case Failure(:final failure):
        if (failure is NotFoundSupabaseFailure || failure.code == '404') {
          return const Failure(MeetingNotFoundFailure());
        }
        return const Failure(MeetingDetailsFailure());
      case Success(:final data):
        final meeting = data.data;
        if (meeting == null) {
          return const Failure(MeetingDetailsFailure());
        }
        return Success<MeetingDetailsEntity, GroupFailure>(meeting.toDomain());
    }
  }

  @override
  Future<Result<NextEventEntity?, GroupFailure>> getNextEvent(
    String groupId,
  ) async {
    final result = await supabaseService.invokeFunction<NextEventModel?>(
      functionName: 'get-group-next-event?group_id=$groupId',
      decoder: NextEventModel.fromEnvelope,
    );

    switch (result) {
      case Failure():
        return const Failure(GroupNextEventFailure());
      case Success(:final data):
        return Success(data.data?.toDomain());
    }
  }

  @override
  Future<Result<void, GroupFailure>> setMeetingPresence(
    String meetingId,
    MeetingPresenceResponse response,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'set-meeting-attendance-response',
      body: {
        'meeting_id': meetingId,
        'presence_status': switch (response) {
          MeetingPresenceResponse.present => 'PRESENT',
          MeetingPresenceResponse.absent => 'ABSENT',
        },
      },
    );

    return switch (result) {
      Failure() => const Failure(GroupMeetingPresenceFailure()),
      Success() => const Success(null),
    };
  }

  @override
  Future<Result<List<MeetingPhotoEntity>, GroupFailure>> getMeetingPhotos(
    String meetingId,
  ) async {
    final result = await supabaseService
        .invokeFunction<List<MeetingPhotoModel>>(
          functionName: 'get-meeting-photos?meeting_id=$meetingId',
          decoder: MeetingPhotoModel.listFromEnvelope,
        );

    switch (result) {
      case Failure():
        return const Failure(MeetingPhotosFailure());
      case Success(:final data):
        final photos = data.data;
        if (photos == null) return const Failure(MeetingPhotosFailure());
        return Success(
          photos.map((photo) => photo.toDomain()).toList(growable: false),
        );
    }
  }

  @override
  Future<Result<MeetingPhotoEntity, GroupFailure>> addMeetingPhoto(
    String meetingId,
    String photoId,
    Uint8List bytes,
    String contentType,
  ) async {
    final result = await supabaseService.invokeFunction<MeetingPhotoModel>(
      functionName: 'add-meeting-photo',
      body: {
        'meeting_id': meetingId,
        'photo_id': photoId,
        'content_type': contentType,
        'data_base64': await compute(base64Encode, bytes),
      },
      decoder: MeetingPhotoModel.fromEnvelope,
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(_uploadFailure(failure.code));
      case Success(:final data):
        final photo = data.data;
        if (photo == null) return const Failure(MeetingPhotoUploadFailure());
        return Success(photo.toDomain());
    }
  }

  static const _rejectedUploadCodes = {'400', '403', '404', '413', '422'};

  GroupFailure _uploadFailure(String? code) {
    if (code == '409') return const MeetingPhotoLimitFailure();
    if (_rejectedUploadCodes.contains(code)) {
      return const MeetingPhotoRejectedFailure();
    }
    return const MeetingPhotoUploadFailure();
  }
}
