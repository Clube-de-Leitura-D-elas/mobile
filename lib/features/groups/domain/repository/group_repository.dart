import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

abstract class GroupRepository {
  Future<Result<List<GroupEntity>, GroupFailure>> getMyGroups();

  Future<Result<GroupDetailsEntity, GroupFailure>> getGroupDetails(
    String groupId,
  );

  Future<Result<List<GroupMeeting>, GroupFailure>> getEventHistory(
    String groupId,
  );
}
