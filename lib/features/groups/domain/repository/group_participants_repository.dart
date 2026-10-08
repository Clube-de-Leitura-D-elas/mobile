import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';

abstract class GroupParticipantsRepository {
  /// Returns the group's participants, coordinators first and the rest in
  /// alphabetical order.
  Future<Result<List<GroupParticipantEntity>, GroupFailure>> getParticipants(
    String groupId,
  );
}
