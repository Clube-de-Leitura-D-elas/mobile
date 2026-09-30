import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';

abstract class GroupRepository {
  Future<Result<List<GroupEntity>, GroupFailure>> getMyGroups();

  Future<Result<GroupDetailsEntity, GroupFailure>> getGroupDetails(
    String groupId,
  );

  Future<Result<List<GroupMeeting>, GroupFailure>> getEventHistory(
    String groupId,
  );

  /// Retorna o próximo evento agendado do grupo, ou null se não houver.
  Future<Result<NextEventEntity?, GroupFailure>> getNextEvent(String groupId);
}
