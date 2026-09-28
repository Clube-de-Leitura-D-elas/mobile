import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';

abstract class GroupRepository {
  Future<Result<GroupDetailsEntity, GroupFailure>> getGroupDetails(
    String groupId,
  );
}
