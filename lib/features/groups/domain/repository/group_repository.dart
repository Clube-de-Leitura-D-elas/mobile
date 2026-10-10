import 'dart:typed_data';

import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';

abstract class GroupRepository {
  Future<Result<List<GroupEntity>, GroupFailure>> getMyGroups();

  Future<Result<GroupDetailsEntity, GroupFailure>> getGroupDetails(
    String groupId,
  );

  Future<Result<List<GroupMeeting>, GroupFailure>> getEventHistory(
    String groupId,
  );

  Future<Result<MeetingDetailsEntity, GroupFailure>> getMeetingDetails(
    String meetingId,
  );

  /// Retorna o próximo evento agendado do grupo, ou null se não houver.
  Future<Result<NextEventEntity?, GroupFailure>> getNextEvent(String groupId);

  Future<Result<void, GroupFailure>> setMeetingInvitationResponse(
    String meetingId,
    MeetingInvitationStatus response,
  );

  Future<Result<List<MeetingPhotoEntity>, GroupFailure>> getMeetingPhotos(
    String meetingId,
  );

  Future<Result<MeetingPhotoEntity, GroupFailure>> addMeetingPhoto(
    String meetingId,
    String photoId,
    Uint8List bytes,
    String contentType,
  );
}
