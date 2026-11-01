import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/data/models/group_event_history_model.dart';
import 'package:mobile/features/groups/data/models/group_model.dart';
import 'package:mobile/features/groups/data/models/meeting_attendance_model.dart';
import 'package:mobile/features/groups/data/models/meeting_details_model.dart';
import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/data/models/meeting_photos_model.dart';
import 'package:mobile/features/groups/data/models/meeting_tasks_model.dart';
import 'package:mobile/features/groups/data/models/next_event_model.dart';
import 'package:mobile/features/groups/data/models/place_suggestion_model.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';
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
  Future<Result<void, GroupFailure>> setMeetingInvitationResponse(
    String meetingId,
    MeetingInvitationStatus response,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'set-meeting-attendance-response',
      body: {
        'meeting_id': meetingId,
        'invitation_status': switch (response) {
          MeetingInvitationStatus.confirmed => 'CONFIRMED',
          MeetingInvitationStatus.declined => 'DECLINED',
          MeetingInvitationStatus.pending => 'PENDING',
        },
      },
    );

    return switch (result) {
      Failure() => const Failure(GroupMeetingInvitationResponseFailure()),
      Success() => const Success(null),
    };
  }

  @override
  Future<Result<MeetingPhotosEntity, GroupFailure>> getMeetingPhotos(
    String meetingId,
  ) async {
    final result = await supabaseService.invokeFunction<MeetingPhotosModel>(
      functionName: 'get-meeting-photos?meeting_id=$meetingId',
      decoder: MeetingPhotosModel.fromEnvelope,
    );

    switch (result) {
      case Failure():
        return const Failure(MeetingPhotosFailure());
      case Success(:final data):
        final photos = data.data;
        if (photos == null) return const Failure(MeetingPhotosFailure());
        return Success(photos.toDomain());
    }
  }

  @override
  Future<Result<MeetingPhotoEntity, GroupFailure>> addMeetingPhoto(
    String meetingId,
    String photoId,
    Uint8List bytes,
    String contentType, {
    String? caption,
  }) async {
    final body = <String, dynamic>{
      'meeting_id': meetingId,
      'photo_id': photoId,
      'content_type': contentType,
      'data_base64': await compute(base64Encode, bytes),
    };
    if (caption != null) {
      body['caption'] = caption;
    }

    final result = await supabaseService.invokeFunction<MeetingPhotoModel>(
      functionName: 'add-meeting-photo',
      body: body,
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

  @override
  Future<Result<List<MeetingAttendanceEntity>, GroupFailure>>
  getMeetingAttendance(String meetingId) async {
    final result = await supabaseService
        .invokeFunction<List<MeetingAttendanceModel>>(
          functionName:
              'get-meeting-attendance?meeting_id=${Uri.encodeQueryComponent(meetingId)}',
          decoder: MeetingAttendanceModel.listFromJson,
        );

    switch (result) {
      case Failure():
        return const Failure(MeetingAttendanceFailure());
      case Success(:final data):
        final items = data.data;
        if (items == null) {
          return const Failure(MeetingAttendanceFailure());
        }

        final entities = items.map((m) => m.toDomain()).toList()
          ..sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));
        return Success(entities);
    }
  }

  @override
  Future<Result<void, GroupFailure>> setMeetingPresence(
    String meetingId,
    List<String> presentUserIds,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'set-meeting-presence',
      body: {'meeting_id': meetingId, 'present_user_ids': presentUserIds},
    );

    return switch (result) {
      Failure(:final failure) when failure.code == '403' => const Failure(
        MeetingPresenceForbiddenFailure(),
      ),
      Failure(:final failure) when failure.code == '409' => const Failure(
        MeetingPresenceAlreadyRegisteredFailure(),
      ),
      Failure() => const Failure(MeetingPresenceFailure()),
      Success() => const Success(null),
    };
  }

  @override
  Future<Result<MeetingTasksEntity, GroupFailure>> getMeetingTasks(
    String meetingId,
  ) async {
    final result = await supabaseService.invokeFunction<MeetingTasksModel>(
      functionName:
          'get-meeting-tasks?meeting_id=${Uri.encodeQueryComponent(meetingId)}',
      decoder: MeetingTasksModel.fromJson,
    );
    return switch (result) {
      Failure() => const Failure(MeetingTasksFailure()),
      Success(:final data) when data.data != null => Success(
        data.data!.toDomain(),
      ),
      Success() => const Failure(MeetingTasksFailure()),
    };
  }

  @override
  Future<Result<void, GroupFailure>> concludeMeeting(String meetingId) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'conclude-meeting',
      body: {'meeting_id': meetingId},
    );
    return switch (result) {
      Failure() => const Failure(MeetingConclusionFailure()),
      Success() => const Success(null),
    };
  }

  static const _photoNotFoundMessage = 'photo not found in this meeting';

  @override
  Future<Result<void, GroupFailure>> deleteMeetingPhoto(
    String meetingId,
    String photoId,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'delete-meeting-photo',
      body: {'meeting_id': meetingId, 'photo_id': photoId},
    );
    return switch (result) {
      // A foto já não está no encontro (outra pessoa removeu antes). Outros
      // 404 (encontro inexistente, função fora do ar) continuam sendo erro.
      Failure(:final failure)
          when failure.code == '404' &&
              failure.message == _photoNotFoundMessage =>
        const Success(null),
      Failure() => const Failure(MeetingPhotoDeleteFailure()),
      Success() => const Success(null),
    };
  }

  @override
  Future<Result<String?, GroupFailure>> updateMeetingPromoText(
    String meetingId,
    String text,
  ) async {
    final result = await supabaseService.invokeFunction<String?>(
      functionName: 'update-meeting-promo-text',
      body: {'meeting_id': meetingId, 'promo_text': text},
      decoder: _promoTextFromEnvelope,
    );
    return switch (result) {
      Failure() => const Failure(MeetingPromoTextUpdateFailure()),
      Success(:final data) => Success(data.data),
    };
  }

  static String? _promoTextFromEnvelope(dynamic json) {
    final promoText = (json as Map<String, dynamic>)['promo_text'];
    if (promoText != null && promoText is! String) {
      throw const FormatException('Invalid promo text response.');
    }
    return promoText as String?;
  }

  /// Ordenação alfabética insensível a acentos ("Ágata" junto de "Ana").
  static String _sortKey(String name) {
    const accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const plain = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final rune in name.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = accented.indexOf(char);
      buffer.write(index == -1 ? char : plain[index]);
    }
    return buffer.toString();
  }

  @override
  Future<Result<List<PlaceSuggestionEntity>, GroupFailure>> searchPlaces(
    String query,
  ) async {
    final result = await supabaseService
        .invokeFunction<List<PlaceSuggestionModel>>(
          functionName:
              'search-places?query=${Uri.encodeQueryComponent(query)}',
          decoder: PlaceSuggestionModel.listFromEnvelope,
        );

    switch (result) {
      case Failure():
        return const Failure(PlaceSearchFailure());
      case Success(:final data):
        final places = data.data;
        if (places == null) return const Failure(PlaceSearchFailure());
        return Success(
          places.map((place) => place.toDomain()).toList(growable: false),
        );
    }
  }

  @override
  Future<Result<void, GroupFailure>> updateMeeting({
    required String meetingId,
    required DateTime date,
    String? googlePlaceId,
    String? description,
  }) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'update-meeting',
      body: {
        'meeting_id': meetingId,
        'date': date.toUtc().toIso8601String(),
        'google_place_id': ?googlePlaceId,
        'description': description,
      },
    );

    return switch (result) {
      Failure(:final failure) => Failure(_updateMeetingFailure(failure.code)),
      Success() => const Success(null),
    };
  }

  GroupFailure _updateMeetingFailure(String? code) => switch (code) {
    '403' || '409' => const MeetingNotEditableFailure(),
    _ => const MeetingUpdateFailure(),
  };
}
