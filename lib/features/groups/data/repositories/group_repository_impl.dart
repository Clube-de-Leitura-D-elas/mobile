import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';
import 'package:mobile/features/groups/data/models/group_event_history_model.dart';
import 'package:mobile/features/groups/data/models/meeting_details_model.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseService supabaseService;

  const GroupRepositoryImpl({required this.supabaseService});

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
}
